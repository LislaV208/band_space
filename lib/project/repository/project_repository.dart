import 'package:band_space/data_sources/firebase_data_source.dart';
import 'package:band_space/project/model/project.dart';

class ProjectRepository {
  const ProjectRepository(this.dataSource);

  final FirebaseDataSource dataSource;

  Future<List<Project>> fetchProjects() async {
    return dataSource.fetchProjects();
  }

  Future<Project> fetchProject(String projectId) async {
    return dataSource.fetchProject(projectId);
  }

  Future<String> addProject(String name) async {
    return dataSource.addProject(name);
  }
}
