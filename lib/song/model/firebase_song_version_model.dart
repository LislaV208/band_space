// ignore_for_file: non_constant_identifier_names

import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSongVersionModel extends SongVersionModel {
  const FirebaseSongVersionModel({
    required super.version_number,
    required super.timestamp,
    required super.file,
  });

  factory FirebaseSongVersionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseSongVersionModel(
      version_number: data['version_number'] ?? 0,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      file: data['file'] != null
          ? VersionFileModel.fromMap(
              data['file'],
            )
          : null,
    );
  }
}
