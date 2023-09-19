import 'package:band_space/project/exceptions/project_exceptions.dart';
import 'package:band_space/project/model/firebase_project_model.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/song/model/firebase/firebase_song_model.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/model/version_file_model.dart';
import 'package:band_space/user/model/firebase_user_model.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProjectRepository {
  final String projectId;
  final String userId;
  final FirebaseFirestore db;
  final FirebaseStorage storage;

  const ProjectRepository({
    required this.projectId,
    required this.userId,
    required this.db,
    required this.storage,
  });

  DocumentReference get _userRef => db.collection('users').doc(userId);
  DocumentReference get _projectRef => db.collection('projects').doc(projectId);

  Stream<ProjectModel> getProject() {
    return db.collection('projects').doc(projectId).snapshots().map(
      (doc) {
        if (!doc.exists) {
          throw ProjectNotFoundException();
        }

        return FirebaseProjectModel.fromDocument(doc);
      },
    );
  }

  Future<void> deleteProject() async {
    final projectSongs = await db
        .collection('songs')
        .where(
          'project_id',
          isEqualTo: _projectRef,
        )
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
          await storage.ref(path).delete();
        }
      }
    }

    await db.runTransaction((transaction) async {
      for (final songDoc in projectSongs.docs) {
        final versions = await songDoc.reference.collection('versions').get();

        for (final versionDoc in versions.docs) {
          transaction.delete(versionDoc.reference);
        }

        transaction.delete(songDoc.reference);
      }

      transaction.delete(_projectRef);
    });
  }

  Future<List<UserModel>> fetchProjectMembers() async {
    final projectDoc = await _projectRef.get();
    List<UserModel> members = await _fetchMembers(
      List<DocumentReference>.from(projectDoc['owners']),
    );

    return members;
  }

  Future<void> addMemberToProject() async {
    final projectDoc = await _projectRef.get();
    final members = List<DocumentReference>.from(projectDoc['owners']);
    if (members.contains(_userRef)) {
      throw DuplicateProjectMemberException();
    }

    members.add(_userRef);

    await projectDoc.reference.update({'owners': members});
  }

  Stream<List<SongModel>> getSongs() {
    final queryStream = db
        .collection('songs')
        .where(
          'project_id',
          isEqualTo: _projectRef,
        )
        .orderBy('created_at', descending: true)
        .snapshots();

    return queryStream.map(
      (query) {
        return query.docs
            .map(
              (doc) => FirebaseSongModel.fromDocument(doc, null),
            )
            .toList();
      },
    );
  }

  Future<String> addSong(
    SongUploadData uploadData,
  ) async {
    const versionNumber = 1;
    final timestamp = Timestamp.now();

    try {
      final newSongRef = db.collection('songs').doc();
      Map<String, dynamic>? versionData;

      if (uploadData.file != null) {
        final file = uploadData.file!;

        final storageFileName = '${projectId}_${newSongRef.id}_$versionNumber.${file.extension}';
        final storageRef = storage.ref().child(storageFileName);
        final uploadSnapshot = await storageRef.putData(
          file.data,
          SettableMetadata(
            contentType: file.mimeType,
          ),
        );
        final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

        versionData = {
          'version_number': versionNumber,
          'timestamp': timestamp,
          'file': {
            'original_name': file.name,
            'storage_name': '${projectId}_${newSongRef.id}_$versionNumber.${file.extension}',
            'size': file.size,
            'duration': file.duration,
            'mime_type': file.mimeType,
            'download_url': downloadUrl,
          }
        };
      }

      await db.runTransaction((transaction) async {
        DocumentReference? versionRef;

        if (versionData != null) {
          final versionDoc = newSongRef.collection('versions').doc();
          transaction.set(versionDoc, versionData);

          versionRef = (await versionDoc.get()).reference;
        }

        transaction.set(newSongRef, {
          'created_at': timestamp,
          'project_id': _projectRef,
          'title': uploadData.title,
          'state': uploadData.state.value,
          'active_version': versionRef,
        });
      });

      return newSongRef.id;
    } catch (e) {
      print("Error occurred: $e");

      throw Exception("Failed to add song: $e");
    }
  }

  Future<List<UserModel>> _fetchMembers(
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
