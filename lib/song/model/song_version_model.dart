// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_file_model.dart';

class SongVersionModel extends Equatable {
  final String id;
  final String version_number;
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
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'file': file?.toMap(),
      'comment': comment,
    };
  }
}
