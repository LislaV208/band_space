import 'package:band_space/song/model/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SongRepository {
  SongRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  late final _projectsRef = _db.collection('projects');
  late final _songsRef = _db.collection('songs');

  Future<List<Song>> fetchSongs(String projectId) async {
    final snapshot = await _songsRef
        .where('project_ref', isEqualTo: _projectsRef.doc(projectId))
        .get();
    final songs = snapshot.docs.map((doc) {
      final data = doc.data();
      return Song.fromMap(data);
    }).toList();

    return songs;
  }

  Future<Song> fetchSong(String songId) async {
    final snapshot = await _songsRef.doc(songId).get();
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Nie ma takiego utworu');
    }

    final song = Song.fromMap(data);
    return song;
  }

  Future<String> addSong(
    String projectId,
    String title,
    PlatformFile? file,
    String? tempo,
    String? lyrics,
  ) async {
    final timestamp = DateTime.timestamp().toIso8601String();

    final newSongRef = await _songsRef.add({
      'created_at': timestamp,
      'modified_at': timestamp,
      'project_ref': _projectsRef.doc(projectId),
      'title': title,
      'tempo': tempo,
      'lyrics': lyrics,
    });

    newSongRef.update({
      'id': newSongRef.id,
    });

    if (file != null) {
      Exception? uploadException;
      try {
        final mimeType = 'audio/mpeg'; //TODO: get actual mime type from file

        final storagePath =
            '/projects/$projectId/${newSongRef.id}/${file.name}';
        final storageRef = _storage.ref(storagePath);
        final taskSnapshot = await storageRef.putData(
          file.bytes!,
          SettableMetadata(
            contentType: mimeType,
          ),
        );
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await newSongRef.update({
          'file': {
            'name': file.name,
            'size': file.size,
            'mime_type': mimeType,
            'storage_path': storagePath,
            'download_url': downloadUrl,
            //TODO: add duration
          },
        });
      } on Exception catch (e) {
        uploadException = e;
      }

      if (uploadException != null) {
        newSongRef.delete();

        throw uploadException;
      }
    }

    return newSongRef.id;
  }

  Future<void> deleteSong(Song song) async {
    if (song.file != null) {
      final storagePath = song.file!.storage_path;
      await _storage.ref(storagePath).delete();
    }

    await _songsRef.doc(song.id).delete();
  }
}
