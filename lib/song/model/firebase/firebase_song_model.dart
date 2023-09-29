// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/song/model/song_model.dart';

class FirebaseSongModel extends SongModel {
  const FirebaseSongModel({
    required super.id,
    required super.created_at,
    required super.title,
    required super.current_version_id,
  });

  factory FirebaseSongModel.create(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseSongModel(
      id: doc.id,
      created_at: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      title: data['title'] ?? '',
      current_version_id: (data['current_version'] as DocumentReference).id,
    );
  }
}
