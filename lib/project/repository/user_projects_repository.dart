import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/project/model/firebase_project_model.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProjectsRepository {
  final String userId;
  final FirebaseFirestore db;

  const UserProjectsRepository({
    required this.userId,
    required this.db,
  });

  DocumentReference get _userRef => db.collection(FirestoreCollectionNames.users).doc(userId);
  CollectionReference get _projectsRef => db.collection(FirestoreCollectionNames.projects);

  Stream<List<ProjectModel>> getProjects() {
    return _projectsRef
        .where(
          'owners',
          arrayContains: _userRef,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FirebaseProjectModel.fromDocument(doc),
              )
              .toList(),
        );
  }

  Future<String> addProject(String name) async {
    final newProjectRef = await _projectsRef.add({
      'created_at': Timestamp.now(),
      'name': name,
      'created_by': _userRef,
      'owners': [_userRef],
    });

    return newProjectRef.id;
  }
}
