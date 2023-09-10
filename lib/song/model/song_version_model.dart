// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_file_model.dart';

class SongVersionModel extends Equatable {
  final int version_number;
  final DateTime? timestamp;
  final VersionFileModel? file;

  const SongVersionModel({
    required this.version_number,
    required this.timestamp,
    required this.file,
  });

  @override
  List<Object?> get props => [version_number, timestamp, file];

  Map<String, dynamic> toMap() {
    return {
      'version_number': version_number,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'file': file?.toMap(),
    };
  }
}
