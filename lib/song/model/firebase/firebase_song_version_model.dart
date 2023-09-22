// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';

class FirebaseSongVersionModel extends SongVersionModel {
  const FirebaseSongVersionModel({
    required super.id,
    required super.version_number,
    required super.timestamp,
    required super.file,
    required super.comment,
  });

  factory FirebaseSongVersionModel.fromDocument(DocumentSnapshot doc, String versionNumber) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseSongVersionModel(
      id: doc.id,
      version_number: versionNumber,
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null,
      file: data['file'] != null
          ? VersionFileModel.fromMap(
              data['file'],
            )
          : null,
      comment: data['comment'] ?? '',
    );
  }
}
