import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/project/model/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectDataSource {
  ProjectDataSource(this.auth, this.db);

  final AuthService auth;
  final FirebaseFirestore db;

  late final projectsRef = db.collection('projects');

  String get _userId => auth.user!.id;

  Future<List<Project>> fetchProjects() async {
    final snapshot =
        await projectsRef.where('user_id', isEqualTo: _userId).get();
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
}
