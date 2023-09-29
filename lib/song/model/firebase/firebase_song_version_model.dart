// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';

class FirebaseSongVersionModel extends SongVersionModel {
  const FirebaseSongVersionModel({
    required super.id,
    required super.timestamp,
    required super.file,
    required super.comment,
    required super.is_current,
  });

  factory FirebaseSongVersionModel.create({
    required DocumentSnapshot doc,
    required bool isCurrent,
  }) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseSongVersionModel(
      id: doc.id,
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null,
      file: data['file'] != null
          ? VersionFileModel.fromMap(
              data['file'],
            )
          : null,
      comment: data['comment'] ?? '',
      is_current: isCurrent,
    );
  }
}
