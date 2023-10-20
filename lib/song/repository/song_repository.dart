import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/song/exceptions/song_exceptions.dart';
import 'package:band_space/song/model/firebase/firebase_song_model.dart';
import 'package:band_space/song/model/firebase/firebase_song_version_model.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/model/song_version_model.dart';

class SongRepository extends FirestoreRepository {
  final String songId;

  final FirebaseStorage storage;

  SongRepository({
    required super.db,
    required this.songId,
    required this.storage,
  });

  DocumentReference get _songRef => db.collection(FirestoreCollectionNames.songs).doc(songId);
  Query<Map<String, dynamic>> get _versionsQuery => db
      .collection(
        FirestoreCollectionNames.versions,
      )
      .where(
        'song',
        isEqualTo: _songRef,
      );

  Stream<SongModel> get() {
    final docSnapshot = _songRef.snapshots();

    return docSnapshot.map((doc) {
      log('SONG DOC CHANGE: ${doc.id}');

      if (!doc.exists) {
        log('Song not found!');
        throw SongNotFoundException();
      }

      return FirebaseSongModel.create(doc);
    });
  }

  Future<void> changeTitle(String title) async {
    await _songRef.update({'title': title.trim()});
  }

  Future<SongVersionModel> fetchCurrentVersion() async {
    final songDoc = await _songRef.get();
    final data = songDoc.data() as Map<String, dynamic>;
    final currentVersionRef = data['current_version'] as DocumentReference;

    return FirebaseSongVersionModel.create(doc: await currentVersionRef.get(), isCurrent: true);
  }

  Future<void> delete() async {
    final pathsOfFilesToRemove = <String>[];

    await db.runTransaction(
      (transaction) async {
        pathsOfFilesToRemove.addAll(
          await deleteSong(transaction, _songRef),
        );
      },
    );

    for (final path in pathsOfFilesToRemove) {
      await storage.ref(path).delete();
    }
  }

  Stream<List<SongVersionModel>> getVersionHistory() {
    final queryStream = _versionsQuery
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots();

    return queryStream.map((query) => query.docs.mapIndexed(
          (index, doc) {
            final isCurrent = index == 0;

            return FirebaseSongVersionModel.create(doc: doc, isCurrent: isCurrent);
          },
        ).toList());
  }

  Future<SongVersionModel?> addVersion(
    SongUploadFile uploadFile,
    String comment,
    bool copyMarkers,
    bool keepMarkersComments,
  ) async {
    DocumentReference<Map<String, dynamic>>? currentVersionRef;
    DocumentReference<Map<String, dynamic>>? newVersionRef;

    await db.runTransaction((transaction) async {
      newVersionRef = db.collection(FirestoreCollectionNames.versions).doc();

      final storageRef = storage.ref('audio').child(newVersionRef!.id);
      final uploadSnapshot = await storageRef.putData(
        uploadFile.data,
        SettableMetadata(
          contentType: uploadFile.mimeType,
        ),
      );
      final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

      //TODO: refactor
      final duration = (await AudioPlayer().setUrl(downloadUrl))?.inMilliseconds ?? 0;

      log('song duration: ${duration}s');

      if (copyMarkers) {
        final songData = (await _songRef.get()).data() as Map<String, dynamic>;
        currentVersionRef = songData['current_version'] as DocumentReference<Map<String, dynamic>>;

        final markersDocs =
            (await db.collection(FirestoreCollectionNames.markers).where('version', isEqualTo: currentVersionRef).get())
                .docs;

        for (final marker in markersDocs) {
          var data = marker.data();
          data['version'] = newVersionRef;

          final start = data['start_position'] as int?;
          final end = data['end_position'] as int?;

          if (start != null && start <= duration) {
            if (end != null && end > duration) {
              continue;
            }

            final newMarkerRef = db.collection(FirestoreCollectionNames.markers).doc();

            transaction.set(newMarkerRef, data);

            if (keepMarkersComments) {
              final commentsDocs = (await db
                      .collection(FirestoreCollectionNames.comments)
                      .where('parent', isEqualTo: marker.reference)
                      .get())
                  .docs;

              for (final comment in commentsDocs) {
                data = comment.data();
                data['parent'] = newMarkerRef;

                final newCommentRef = db.collection(FirestoreCollectionNames.comments).doc();
                transaction.set(newCommentRef, data);
              }
            }
          }
        }
      }

      //TODO: zrobić klasę z toMap()
      transaction.set(
        newVersionRef!,
        {
          'song': _songRef,
          'timestamp': Timestamp.now(),
          'comment': comment,
          'file': {
            'name': uploadFile.name,
            'storage_path': storageRef.fullPath,
            'size': uploadFile.size,
            'duration': duration,
            'mime_type': uploadFile.mimeType,
            'download_url': downloadUrl,
          }
        },
      );

      transaction.update(_songRef, {'current_version': newVersionRef});
    });

    if (newVersionRef != null) {
      final doc = await newVersionRef!.get();

      return FirebaseSongVersionModel.create(doc: doc, isCurrent: true);
    }

    return null;
  }
}
