import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/file_storage/remote_song_file_storage.dart';
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
  final RemoteSongFileStorage remoteSongFileStorage;

  const ProjectRepository({
    required super.db,
    required this.projectId,
    required this.userId,
    required this.storage,
    required this.remoteSongFileStorage,
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

    return queryStream.asyncMap(
      (query) async => await Future.wait(
        query.docs.map((doc) async => await FirebaseSongModel.fromFirestore(db, doc)).toList(),
      ),
    );
  }

  Future<String> addSong(
    SongUploadData uploadData,
  ) async {
    final timestamp = Timestamp.now();
    DocumentReference<Map<String, dynamic>>? versionRef;
    final newSongRef = db.collection(FirestoreCollectionNames.songs).doc();

    try {
      await db.runTransaction((transaction) async {
        versionRef = db.collection('versions').doc();
        final file = uploadData.file;

        //TODO: zrobić klasę z toMap()
        transaction.set(
          versionRef!,
          {
            'song': newSongRef,
            'timestamp': timestamp,
            'uploader': _userRef,
            'file': {
              'name': file.name,
              'size': file.size,
              'mime_type': file.mimeType,
            }
          },
        );

        //TODO: zrobić klasę z toMap()
        transaction.set(newSongRef, {
          'created_at': timestamp,
          'project': _projectRef,
          'title': uploadData.title,
          'current_version': versionRef,
          'upload_in_progress': true,
        });
      });
    } catch (e) {
      print("Error occurred: $e");

      //TODO: obsłuzyc lepiej
      throw Exception("Failed to add song: $e");
    }

    if (versionRef != null) {
      remoteSongFileStorage.upload(
        name: versionRef!.id,
        file: uploadData.file,
        onComplete: (snapshot) async {
          final downloadUrl = await snapshot.ref.getDownloadURL();
          final duration = (await AudioPlayer().setUrl(downloadUrl))?.inMilliseconds;

          final docSnapshot = await versionRef!.get();
          final data = docSnapshot.data();
          if (data != null) {
            final file = data['file'] as Map<String, dynamic>;
            file['storage_path'] = snapshot.ref.fullPath;
            file['duration'] = duration;
            file['download_url'] = downloadUrl;

            await versionRef!.update({'file': file});

            newSongRef.update({'upload_in_progress': FieldValue.delete()});
          }
        },
      );
    }

    return newSongRef.id;
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
