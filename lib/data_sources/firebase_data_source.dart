import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/project/model/project.dart';
import 'package:band_space/song/model/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataSource {
  FirebaseDataSource(this.auth, this.db);

  final AuthService auth;
  final FirebaseFirestore db;

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
}
