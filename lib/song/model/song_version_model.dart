// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_file_model.dart';

class SongVersionModel extends Equatable {
  final String id;
  final int version_number;
  final DateTime? timestamp;
  final VersionFileModel? file;
  final String comment;

  const SongVersionModel({
    required this.id,
    required this.version_number,
    required this.timestamp,
    required this.file,
    required this.comment,
  });

  @override
  List<Object?> get props => [id, version_number, timestamp, file, comment];

  Map<String, dynamic> toMap() {
    return {
      'version_number': version_number,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'file': file?.toMap(),
      'comment': comment,
    };
  }
}
