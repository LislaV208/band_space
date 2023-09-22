import 'dart:developer';

import 'package:band_space/song/model/firebase/firebase_song_model.dart';
import 'package:band_space/song/model/firebase/firebase_song_version_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/song/exceptions/song_exceptions.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';

class SongRepository {
  final String songId;
  final FirebaseFirestore db;
  final FirebaseStorage storage;

  SongRepository({
    required this.songId,
    required this.db,
    required this.storage,
  });

  DocumentReference get _songRef => db.collection('songs').doc(songId);
  Query<Map<String, dynamic>> get _versionsQuery => db.collection('versions').where(
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

  // things to remove
  // - song
  // - song's versions
  // - song's version's markers
  // - song's comments
  // - song's version's marker's comments
  // - song's version's storage files
  Future<void> delete() async {
    //TODO: usuwanie komentarzy i znaczników utworu

    await db.runTransaction(
      (transaction) async {
        final versionsResult = await _versionsQuery.get();

        final pathsOfFilesToRemove = <String>[];

        for (final versionDoc in versionsResult.docs) {
          final file = versionDoc['file'] != null
              ? VersionFileModel.fromMap(
                  versionDoc['file'],
                )
              : null;
          final path = file?.storage_path;

          if (path != null) {
            pathsOfFilesToRemove.add(path);
          }

          final markersResult = await db
              .collection('markers')
              .where(
                'version',
                isEqualTo: versionDoc.reference,
              )
              .get();

          for (final markerDoc in markersResult.docs) {
            final commentsResult = await db
                .collection('comments')
                .where(
                  'parent',
                  isEqualTo: markerDoc.reference,
                )
                .get();

            for (final commentDoc in commentsResult.docs) {
              transaction.delete(commentDoc.reference);
            }

            transaction.delete(markerDoc.reference);
          }

          transaction.delete(versionDoc.reference);
        }

        final commentsResult = await db
            .collection('comments')
            .where(
              'parent',
              isEqualTo: _songRef,
            )
            .get();

        for (final commentDoc in commentsResult.docs) {
          transaction.delete(commentDoc.reference);
        }

        transaction.delete(_songRef);

        for (final path in pathsOfFilesToRemove) {
          await storage.ref(path).delete();
        }
      },
    );
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
      versionRef = db.collection('versions').doc();

      final storageRef = storage.ref('audio').child(versionRef!.id);
      final uploadSnapshot = await storageRef.putData(
        uploadFile.data,
        SettableMetadata(
          contentType: uploadFile.mimeType,
        ),
      );
      final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

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
            'duration': uploadFile.duration,
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
