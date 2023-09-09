// ignore_for_file: non_constant_identifier_names

import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/song_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSongModel extends SongModel {
  const FirebaseSongModel({
    required super.id,
    required super.created_at,
    required super.title,
    required super.state,
  });

  factory FirebaseSongModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseSongModel(
      id: doc.id,
      created_at: DateTime.parse(data['created_at']).toLocal(),
      title: data['title'] ?? '',
      state: SongState.fromString(data['state'] ?? ''),
    );
  }
}
