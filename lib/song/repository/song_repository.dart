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
        .where('project', isEqualTo: _projectsRef.doc(projectId))
        .get();
    final songs = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['project_id'] = projectId;

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
    PlatformFile file,
  ) async {
    final timestamp = DateTime.timestamp().toIso8601String();

    final newSongRef = await _songsRef.add({
      'created_at': timestamp,
      'modified_at': timestamp,
      'project': _projectsRef.doc(projectId),
      'title': title,
    });

    final storagePath = '/songs/$projectId/${newSongRef.id}/${file.name}';
    final storageRef = _storage.ref(storagePath);
    final taskSnapshot =
        await storageRef.putData(file.bytes!, SettableMetadata());
    final url = await taskSnapshot.ref.getDownloadURL();

    await newSongRef.update({
      'file_url': url,
    });

    return newSongRef.id;
  }
}
