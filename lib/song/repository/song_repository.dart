import 'dart:developer';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/song/exceptions/song_exceptions.dart';
import 'package:band_space/song/model/firebase/firebase_song_model.dart';
import 'package:band_space/song/model/firebase/firebase_song_version_model.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:just_audio/just_audio.dart';

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

    return docSnapshot.asyncMap(
      (doc) async {
        if (!doc.exists) {
          log('Song not found!');
          throw SongNotFoundException();
        }

        final data = doc.data() as Map<String, dynamic>?;
        final versionRef = data?['current_version'] as DocumentReference?;

        SongVersionModel? currentVersion;
        if (versionRef != null) {
          final versionNumber = (await _versionsQuery.count().get()).count;

          final versionDoc = await versionRef.get();
          currentVersion = FirebaseSongVersionModel.fromDocument(
            versionDoc,
            versionNumber.toString(),
          );
        }

        return FirebaseSongModel.fromDocument(doc, currentVersion);
      },
    );
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

    return queryStream.map((query) {
      final versionIDs = query.docs.reversed.map((doc) => doc.id).toList();

      return query.docs.map(
        (doc) {
          final versionNumber = versionIDs.indexOf(doc.id) + 1;

          return FirebaseSongVersionModel.fromDocument(doc, versionNumber.toString());
        },
      ).toList();
    });
  }

  Future<SongVersionModel?> addVersion(
    SongUploadFile uploadFile,
    String comment,
  ) async {
    DocumentReference<Map<String, dynamic>>? versionRef;

    await db.runTransaction((transaction) async {
      versionRef = db.collection(FirestoreCollectionNames.versions).doc();

      final storageRef = storage.ref('audio').child(versionRef!.id);
      final uploadSnapshot = await storageRef.putData(
        uploadFile.data,
        SettableMetadata(
          contentType: uploadFile.mimeType,
        ),
      );
      final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

      //TODO: refactor
      final duration = (await AudioPlayer().setUrl(downloadUrl))?.inSeconds;

      log('song duration: ${duration}s');

      //TODO: zrobić klasę z toMap()
      transaction.set(
        versionRef!,
        {
          'song': _songRef,
          'timestamp': Timestamp.now(),
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

      transaction.update(_songRef, {'current_version': versionRef});
    });

    if (versionRef != null) {
      final countQuery = await _versionsQuery.count().get();

      return FirebaseSongVersionModel.fromDocument(
        await versionRef!.get(),
        countQuery.count.toString(),
      );
    }

    return null;
  }
}
