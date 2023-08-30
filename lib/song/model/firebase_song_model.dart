// ignore_for_file: non_constant_identifier_names

import 'package:band_space/song/model/song_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSongModel extends SongModel {
  const FirebaseSongModel({
    required super.id,
    required super.created_at,
    required super.title,
    required super.tempo,
  });

  factory FirebaseSongModel.fromDocument(DocumentSnapshot doc) {
    return FirebaseSongModel(
      id: doc.id,
      created_at: DateTime.parse(doc['created_at']).toLocal(),
      title: doc['title'] ?? '',
      tempo: doc['tempo'],
    );
  }
}
