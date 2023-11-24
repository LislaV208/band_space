// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/user/model/firebase_user_model.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:band_space/utils/file_size.dart';

class FirebaseSongModel extends SongModel {
  const FirebaseSongModel({
    required super.id,
    required super.created_at,
    required super.title,
    required super.comments_count,
    required super.size,
    required super.uploader,
    required super.current_version_id,
    required super.upload_in_progress,
  });

  static Future<SongModel> fromFirestore(FirebaseFirestore db, DocumentSnapshot<Map<String, dynamic>> document) async {
    final songData = document.data();
    final versionRef = songData?['current_version'] as DocumentReference?;
    final versionDocument = await db.collection(FirestoreCollectionNames.versions).doc(versionRef?.id).get();
    final versionData = versionDocument.data();
    final fileData = versionData?['file'] as Map<String, dynamic>?;
    final commentsQuery = await versionDocument.reference.collection(FirestoreCollectionNames.comments).limit(1).get();
    final commentsCount = commentsQuery.size;

    final uploaderRef = versionData?['uploader'] as DocumentReference<Map<String, dynamic>>?;
    UserModel? uploader;
    if (uploaderRef != null) {
      final userDoc = await db.collection(FirestoreCollectionNames.users).doc(uploaderRef.id).get();
      uploader = FirebaseUserModel.fromDocument(userDoc);
    }

    return SongModel(
      id: document.id,
      current_version_id: versionRef?.id ?? '',
      created_at: songData?['created_at'] != null ? (songData?['created_at'] as Timestamp).toDate() : null,
      title: songData?['title'] ?? '',
      comments_count: commentsCount,
      size: fileData?['size'] != null ? FileSize.bytes(fileData?['size']) : null,
      uploader: uploader,
      upload_in_progress: songData?['upload_in_progress'] ?? false,
    );
  }
}
