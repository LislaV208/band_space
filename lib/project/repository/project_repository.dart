import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/project/exceptions/project_exceptions.dart';
import 'package:band_space/project/model/firebase_project_model.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/song/model/firebase/firebase_song_model.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/user/model/firebase_user_model.dart';
import 'package:band_space/user/model/user_model.dart';

class ProjectRepository extends FirestoreRepository {
  final String projectId;
  final String userId;

  final FirebaseStorage storage;

  const ProjectRepository({
    required super.db,
    required this.projectId,
    required this.userId,
    required this.storage,
  });

  DocumentReference get _userRef => db.collection(FirestoreCollectionNames.users).doc(userId);
  DocumentReference get _projectRef => db.collection(FirestoreCollectionNames.projects).doc(projectId);

  Stream<ProjectModel> get() {
    return _projectRef.snapshots().map(
      (doc) {
        if (!doc.exists) {
          throw ProjectNotFoundException();
        }

        return FirebaseProjectModel.fromDocument(doc);
      },
    );
  }

  Future<void> changeName(String name) async {
    await _projectRef.update({'name': name.trim()});
  }

  Future<void> delete() async {
    final pathsOfFilesToRemove = <String>[];

    await db.runTransaction(
      (transaction) async {
        pathsOfFilesToRemove.addAll(
          await deleteProject(transaction, _projectRef),
        );
      },
    );

    for (final path in pathsOfFilesToRemove) {
      await storage.ref(path).delete();
    }
  }

  Future<List<UserModel>> fetchMembers() async {
    final projectDoc = await _projectRef.get();
    List<UserModel> members = await _fetchMembers(
      List<DocumentReference>.from(projectDoc['owners']),
    );

    return members;
  }

  Future<void> addMember() async {
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
        .collection(FirestoreCollectionNames.songs)
        .where(
          'project',
          isEqualTo: _projectRef,
        )
        .orderBy('created_at', descending: true)
        .snapshots();

    return queryStream.map(
      (query) {
        return query.docs
            .map(
              (doc) => FirebaseSongModel.create(doc),
            )
            .toList();
      },
    );
  }

  Future<String> addSong(
    SongUploadData uploadData,
  ) async {
    final timestamp = Timestamp.now();

    try {
      final newSongRef = db.collection(FirestoreCollectionNames.songs).doc();

      await db.runTransaction((transaction) async {
        DocumentReference? versionRef;

        if (uploadData.file != null) {
          versionRef = db.collection('versions').doc();
          final file = uploadData.file!;
          final storageRef = storage.ref('audio').child(versionRef.id);
          final uploadSnapshot = await storageRef.putData(
            file.data,
            SettableMetadata(
              contentType: file.mimeType,
            ),
          );
          final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

          //TODO: refactor
          final duration = (await AudioPlayer().setUrl(downloadUrl))?.inMilliseconds;

          log('song duration: ${duration}s');

          //TODO: zrobić klasę z toMap()
          transaction.set(
            versionRef,
            {
              'song': newSongRef,
              'timestamp': timestamp,
              'file': {
                'name': file.name,
                'storage_path': storageRef.fullPath,
                'size': file.size,
                'duration': duration,
                'mime_type': file.mimeType,
                'download_url': downloadUrl,
              }
            },
          );
        }

        //TODO: zrobić klasę z toMap()
        transaction.set(newSongRef, {
          'created_at': timestamp,
          'project': _projectRef,
          'title': uploadData.title,
          'current_version': versionRef,
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
