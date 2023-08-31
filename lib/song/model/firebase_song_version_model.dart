// ignore_for_file: non_constant_identifier_names

import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_file_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSongVersionModel extends SongVersionModel {
  const FirebaseSongVersionModel({
    required super.version_number,
    required super.lyrics,
    required super.timestamp,
    required super.file,
  });

  factory FirebaseSongVersionModel.fromDocument(DocumentSnapshot doc) {
    return FirebaseSongVersionModel(
      version_number: doc['version_number'] ?? 0,
      lyrics: doc['lyrics'],
      timestamp: DateTime.parse(doc['timestamp']).toLocal(),
      file: doc['file'] != null ? VersionFileModel.fromMap(doc['file']) : null,
    );
  }
}
