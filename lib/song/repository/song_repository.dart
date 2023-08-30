import 'dart:developer';

import 'package:band_space/song/exceptions/song_exceptions.dart';
import 'package:band_space/song/model/firebase_song_model.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SongRepository {
  SongRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  late final _projectsRef = _db.collection('projects');
  late final _songsRef = _db.collection('songs');

  Stream<List<SongModel>> getSongs(String projectId) {
    final queryStream = _songsRef
        .where('project_id', isEqualTo: _projectsRef.doc(projectId))
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
    String title,
    PlatformFile? file,
    String? tempo,
  ) async {
    final timestamp = DateTime.timestamp().toIso8601String();

    final newSongRef = await _songsRef.add({
      'created_at': timestamp,
      'project_id': _projectsRef.doc(projectId),
      'title': title,
      'tempo': tempo,
    });

    if (file != null) {
      // Exception? uploadException;
      // try {
      //   final mimeType = 'audio/mpeg'; //TODO: get actual mime type from file

      //   final storagePath =
      //       '/projects/$projectId/${newSongRef.id}/${file.name}';
      //   final storageRef = _storage.ref(storagePath);
      //   final taskSnapshot = await storageRef.putData(
      //     file.bytes!,
      //     SettableMetadata(
      //       contentType: mimeType,
      //     ),
      //   );
      //   final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      //   await newSongRef.update({
      //     'file': {
      //       'name': file.name,
      //       'size': file.size,
      //       'mime_type': mimeType,
      //       'storage_path': storagePath,
      //       'download_url': downloadUrl,
      //       //TODO: add duration
      //     },
      //   });
      // } on Exception catch (e) {
      //   uploadException = e;
      // }

      // if (uploadException != null) {
      //   newSongRef.delete();

      //   throw uploadException;
      // }
    }

    return newSongRef.id;
  }

  Future<void> deleteSong(SongModel song) async {
    // if (song.file != null) {
    //   final storagePath = song.file!.storage_path;
    //   await _storage.ref(storagePath).delete();
    // }

    await _songsRef.doc(song.id).delete();
  }
}
