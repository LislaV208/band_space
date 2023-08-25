import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/project/model/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectRepository {
  ProjectRepository(this._auth, this._db);

  final AuthService _auth;
  final FirebaseFirestore _db;

  late final _userRef = _db.collection('users').doc(_auth.user!.id);
  late final _projectsRef = _db.collection('projects');

  Future<List<Project>> fetchProjects() async {
    final snapshot =
        await _projectsRef.where('owners', arrayContains: _userRef).get();
    final projects = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Project.fromMap(data);
    }).toList();

    return projects;
  }

  Future<Project> fetchProject(String projectId) async {
    final snapshot = await _projectsRef.doc(projectId).get();

    final data = snapshot.data();
    if (data == null) {
      throw Exception('Nie ma takiego projektu');
    }

    final project = Project.fromMap(data);

    return project;
  }

  Future<String> addProject(String name) async {
    final timestamp = DateTime.timestamp().toIso8601String();

    final newProjectRef = await _projectsRef.add({
      'created_at': timestamp,
      'name': name,
      'owners': [_userRef],
    });

    return newProjectRef.id;
  }
}
