import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/project/model/project.dart';
import 'package:band_space/song/model/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDataSource {
  FirebaseDataSource(this.auth, this.db, this.storage);

  final AuthService auth;
  final FirebaseFirestore db;
  final FirebaseStorage storage;

  late final userRef = db.collection('users').doc(auth.user!.id);
  late final projectsRef = db.collection('projects');
  late final songsRef = db.collection('songs');

  Future<List<Project>> fetchProjects() async {
    final snapshot =
        await projectsRef.where('owners', arrayContains: userRef).get();
    final projects = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Project.fromMap(data);
    }).toList();

    return projects;
  }

  Future<Project> fetchProject(String projectId) async {
    final snapshot = await projectsRef.doc(projectId).get();

    final data = snapshot.data();
    if (data == null) {
      throw Exception('Nie ma takiego projektu');
    }

    final project = Project.fromMap(data);

    return project;
  }

  Future<List<Song>> fetchSongs(String projectId) async {
    final snapshot = await songsRef
        .where('project', isEqualTo: projectsRef.doc(projectId))
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
    final snapshot = await songsRef.doc(songId).get();
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

    final newSongRef = await songsRef.add({
      'created_at': timestamp,
      'modified_at': timestamp,
      'project': projectsRef.doc(projectId),
      'title': title,
    });

    final storagePath = '/songs/$projectId/${newSongRef.id}/${file.name}';
    final storageRef = storage.ref(storagePath);
    final taskSnapshot =
        await storageRef.putData(file.bytes!, SettableMetadata());
    final url = await taskSnapshot.ref.getDownloadURL();

    await newSongRef.update({
      'file_url': url,
    });

    return newSongRef.id;
  }
}
