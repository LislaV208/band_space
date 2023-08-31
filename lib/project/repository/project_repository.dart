import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/project/exceptions/project_exceptions.dart';
import 'package:band_space/project/model/firebase_project_model.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/song/model/version_file_model.dart';
import 'package:band_space/user/model/firebase_user_model.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProjectRepository {
  ProjectRepository(this._auth, this._db, this._storage);

  final AuthService _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  DocumentReference get _userRef => _db.collection('users').doc(_auth.user!.id);
  late final _projectsRef = _db.collection('projects');

  Stream<List<ProjectModel>> getProjects() {
    return _projectsRef
        .where('owners', arrayContains: _userRef)
        .snapshots()
        .asyncMap(
      (snapshot) async {
        return await Future.wait(
          snapshot.docs.map(
            (doc) async {
              UserModel creator = FirebaseUserModel.fromDocument(
                await doc['created_by'].get(),
              );
              List<UserModel> owners = await _fetchOwners(
                List<DocumentReference>.from(doc['owners']),
              );

              return FirebaseProjectModel.fromDocument(doc, creator, owners);
            },
          ).toList(),
        );
      },
    );
  }

  Stream<ProjectModel> getProject(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) {
        throw ProjectNotFoundException();
      }

      UserModel creator = FirebaseUserModel.fromDocument(
        await doc['created_by'].get(),
      );
      List<UserModel> owners = await _fetchOwners(
        List<DocumentReference>.from(doc['owners']),
      );

      return FirebaseProjectModel.fromDocument(doc, creator, owners);
    });
  }

  Future<String> addProject(String name) async {
    final timestamp = DateTime.timestamp().toIso8601String();

    final newProjectRef = await _projectsRef.add({
      'created_at': timestamp,
      'name': name,
      'created_by': _userRef,
      'owners': [_userRef],
    });

    return newProjectRef.id;
  }

  Future<void> deleteProject(ProjectModel project) async {
    final projectRef = _projectsRef.doc(project.id);

    final projectSongs = await _db
        .collection('songs')
        .where('project_id', isEqualTo: projectRef)
        .get();

    for (final songDoc in projectSongs.docs) {
      final versions = await songDoc.reference.collection('versions').get();

      for (final versionDoc in versions.docs) {
        final file = versionDoc['file'] != null
            ? VersionFileModel.fromMap(
                versionDoc['file'],
              )
            : null;
        final path = file?.storage_name;

        if (path != null) {
          await _storage.ref(path).delete();
        }
      }
    }

    await _db.runTransaction((transaction) async {
      for (final songDoc in projectSongs.docs) {
        final versions = await songDoc.reference.collection('versions').get();

        for (final versionDoc in versions.docs) {
          transaction.delete(versionDoc.reference);
        }

        transaction.delete(songDoc.reference);
      }

      transaction.delete(projectRef);
    });
  }

  Future<List<UserModel>> _fetchOwners(
    List<DocumentReference> ownerRefs,
  ) async {
    final owners = await Future.wait(
      ownerRefs.map(
        (ownerRef) async {
          final ownerDoc = await ownerRef.get();

          return FirebaseUserModel.fromDocument(ownerDoc);
        },
      ).toList(),
    );

    return owners;
  }
}
