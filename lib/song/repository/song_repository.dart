import 'dart:developer';

import 'package:band_space/song/exceptions/song_exceptions.dart';
import 'package:band_space/song/model/firebase_song_model.dart';
import 'package:band_space/song/model/firebase_song_version_model.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SongRepository {
  SongRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  late final _projectsRef = _db.collection('projects');
  late final _songsRef = _db.collection('songs');

  Stream<List<SongModel>> getSongs(String projectId) {
    final queryStream = _songsRef
        .where(
          'project_id',
          isEqualTo: _projectsRef.doc(projectId),
        )
        .orderBy('created_at', descending: true)
        .snapshots();

    return queryStream.map(
      (query) {
        return query.docs
            .map(
              (doc) => FirebaseSongModel.fromDocument(doc),
            )
            .toList();
      },
    );
  }

  Stream<SongModel> getSong(String songId) {
    final docSnapshot = _songsRef.doc(songId).snapshots();

    return docSnapshot.map(
      (doc) {
        if (!doc.exists) {
          log('Song not found!');
          throw SongNotFoundException();
        }

        return FirebaseSongModel.fromDocument(doc);
      },
    );
  }

  Future<String> addSong(
    String projectId,
    SongUploadData uploadData,
  ) async {
    const versionNumber = 1;
    final timestamp = Timestamp.now();

    try {
      final newSongRef = _songsRef.doc();
      Map<String, dynamic>? versionData;

      if (uploadData.file != null) {
        final file = uploadData.file!;

        final storageFileName =
            '${projectId}_${newSongRef.id}_$versionNumber.${file.extension}';
        final storageRef = _storage.ref().child(storageFileName);
        final uploadSnapshot = await storageRef.putData(
          file.data,
          SettableMetadata(
            contentType: file.mimeType,
          ),
        );
        final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

        versionData = {
          'version_number': versionNumber,
          'timestamp': timestamp,
          'file': {
            'original_name': file.name,
            'storage_name':
                '${projectId}_${newSongRef.id}_$versionNumber.${file.extension}',
            'size': file.size,
            'duration': file.duration,
            'mime_type': file.mimeType,
            'download_url': downloadUrl,
          }
        };
      }

      await _db.runTransaction((transaction) async {
        transaction.set(newSongRef, {
          'created_at': timestamp,
          'project_id': _projectsRef.doc(projectId),
          'title': uploadData.title,
          'state': uploadData.state.value,
        });

        if (versionData != null) {
          transaction.set(newSongRef.collection('versions').doc(), versionData);
        }
      });

      return newSongRef.id;
    } catch (e) {
      print("Error occurred: $e");

      throw Exception("Failed to add song: $e");
    }
  }

  Future<void> deleteSong(SongModel song) async {
    final versionsRef = _songsRef.doc(song.id).collection('versions');
    final versions = await versionsRef.get();

    for (final doc in versions.docs) {
      final file = doc['file'] != null
          ? VersionFileModel.fromMap(
              doc['file'],
            )
          : null;
      final path = file?.storage_name;

      if (path != null) {
        await _storage.ref(path).delete();
      }
    }

    await _db.runTransaction(
      (transaction) async {
        for (final doc in versions.docs) {
          transaction.delete(doc.reference);
        }

        transaction.delete(_songsRef.doc(song.id));
      },
    );
  }

  Future<SongVersionModel> fetchLatestSongVersion(String songId) async {
    final querySnapshot = await _songsRef
        .doc(songId)
        .collection('versions')
        .orderBy('version_number', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No versions found for this song.');
    }

    final version =
        FirebaseSongVersionModel.fromDocument(querySnapshot.docs.first);

    return version;
  }

  Future<List<SongVersionModel>> fetchSongVersionHistory(String songId) async {
    final querySnapshot = await _songsRef
        .doc(songId)
        .collection('versions')
        .orderBy('version_number', descending: true)
        .get();

    final versions = querySnapshot.docs
        .map((doc) => FirebaseSongVersionModel.fromDocument(doc))
        .toList();

    return versions;
  }

  Stream<List<SongVersionModel>> getSongVersionHistory(String songId) {
    final queryStream = _songsRef
        .doc(songId)
        .collection('versions')
        .orderBy('version_number', descending: true)
        .snapshots();

    return queryStream.map((query) {
      return query.docs
          .map((doc) => FirebaseSongVersionModel.fromDocument(doc))
          .toList();
    });
  }

  Future<void> addSongVersion(
    String projectId,
    String songId,
    SongUploadFile uploadFile,
  ) async {
    final versions = _songsRef.doc(songId).collection('versions');

    final versionNumberQuery = await versions
        .orderBy('version_number', descending: true)
        .limit(1)
        .get();

    final lastVersionNumber = versionNumberQuery.docs.isEmpty
        ? 0
        : versionNumberQuery.docs.first['version_number'] as int;
    final newVersionNumber = lastVersionNumber + 1;

    final timestamp = DateTime.timestamp();
    final storageName =
        '${projectId}_${songId}_$newVersionNumber.${uploadFile.extension}';

    final storageFileName =
        '${projectId}_${songId}_$newVersionNumber.${uploadFile.extension}';
    final storageRef = _storage.ref().child(storageFileName);
    final uploadSnapshot = await storageRef.putData(
      uploadFile.data,
      SettableMetadata(
        contentType: uploadFile.mimeType,
      ),
    );

    final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

    final newVersion = SongVersionModel(
      version_number: newVersionNumber,
      timestamp: timestamp,
      file: VersionFileModel(
        original_name: uploadFile.name,
        storage_name: storageName,
        size: uploadFile.size,
        duration: uploadFile.duration,
        mime_type: uploadFile.mimeType,
        download_url: downloadUrl,
      ),
    );

    await versions.add(newVersion.toMap());
  }
}
