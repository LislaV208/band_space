import 'dart:developer';

import 'package:band_space/song/model/firebase/firebase_song_model.dart';
import 'package:band_space/song/model/firebase/firebase_song_version_model.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/song/exceptions/song_exceptions.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';

//TODO: przejść na flat structure w firebase i dostosować w aplikacji

class SongRepository {
  final String songId;
  final FirebaseFirestore db;
  final FirebaseStorage storage;

  SongRepository({
    required this.songId,
    required this.db,
    required this.storage,
  });

  late final _songsRef = db.collection('songs');

  Stream<SongModel> get() {
    final docSnapshot = _songsRef.doc(songId).snapshots();

    return docSnapshot.asyncMap(
      (doc) async {
        if (!doc.exists) {
          log('Song not found!');
          throw SongNotFoundException();
        }

        final versionRef = doc.data()?['active_version'] as DocumentReference?;

        SongVersionModel? activeVersion;
        if (versionRef != null) {
          final versionDoc = await versionRef.get();
          activeVersion = FirebaseSongVersionModel.fromDocument(versionDoc);
        }

        return FirebaseSongModel.fromDocument(doc, activeVersion);
      },
    );
  }

  Future<void> delete() async {
    final versionsRef = _songsRef.doc(songId).collection('versions');
    final versions = await versionsRef.get();

    for (final doc in versions.docs) {
      final file = doc['file'] != null
          ? VersionFileModel.fromMap(
              doc['file'],
            )
          : null;
      final path = file?.storage_name;

      if (path != null) {
        await storage.ref(path).delete();
      }
    }

    await db.runTransaction(
      (transaction) async {
        for (final doc in versions.docs) {
          transaction.delete(doc.reference);
        }

        transaction.delete(_songsRef.doc(songId));
      },
    );
  }

  Future<SongVersionModel> fetchLatestVersion() async {
    final querySnapshot = await _songsRef
        .doc(songId)
        .collection('versions')
        .orderBy(
          'version_number',
          descending: true,
        )
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No versions found for this song.');
    }

    final version = FirebaseSongVersionModel.fromDocument(querySnapshot.docs.first);

    return version;
  }

  Future<List<SongVersionModel>> fetchVersionHistory() async {
    final querySnapshot = await _songsRef
        .doc(songId)
        .collection('versions')
        .orderBy(
          'version_number',
          descending: true,
        )
        .get();

    final versions = querySnapshot.docs.map((doc) => FirebaseSongVersionModel.fromDocument(doc)).toList();

    return versions;
  }

  Stream<List<SongVersionModel>> getVersionHistory() {
    final queryStream = _songsRef
        .doc(songId)
        .collection('versions')
        .orderBy(
          'version_number',
          descending: true,
        )
        .snapshots();

    return queryStream.map((query) {
      return query.docs.map((doc) => FirebaseSongVersionModel.fromDocument(doc)).toList();
    });
  }

  Future<void> addSVersion(
    String projectId,
    SongUploadFile uploadFile,
    String comment,
  ) async {
    final versions = _songsRef.doc(songId).collection('versions');

    final versionNumberQuery = await versions.orderBy('version_number', descending: true).limit(1).get();

    final lastVersionNumber =
        versionNumberQuery.docs.isEmpty ? 0 : versionNumberQuery.docs.first['version_number'] as int;
    final newVersionNumber = lastVersionNumber + 1;

    final storageName = '${projectId}_${songId}_$newVersionNumber.${uploadFile.extension}';
    final storageRef = storage.ref().child(storageName);
    final uploadSnapshot = await storageRef.putData(
      uploadFile.data,
      SettableMetadata(
        contentType: uploadFile.mimeType,
      ),
    );

    final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

    final newVersion = SongVersionModel(
      id: '', // troche średnio XD
      version_number: newVersionNumber,
      timestamp: DateTime.timestamp(),
      comment: comment,
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

    final lastVersionQuery = await versions.orderBy('version_number', descending: true).limit(1).get();

    final lastVersionRef = lastVersionQuery.docs.isEmpty ? null : lastVersionQuery.docs.first.reference;

    _songsRef.doc(songId).update({
      'active_version': lastVersionRef,
    });
  }

  Future<void> setActiveVersion(String versionId) async {
    final versionRef = _songsRef.doc(songId).collection('versions').doc(versionId);

    _songsRef.doc(songId).update({
      'active_version': versionRef,
    });
  }

  Future<void> addMarker(
    String versionId,
    MarkerDTO markerData,
  ) async {
    final newMarkerDoc = _songsRef.doc(songId).collection('versions').doc(versionId).collection('markers').doc();
    await newMarkerDoc.set({
      'name': markerData.name,
      'position': markerData.position,
    });
  }
}
