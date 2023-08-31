// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_file_model.dart';

class SongVersionModel extends Equatable {
  final int version_number;
  final String? lyrics;
  final DateTime timestamp;
  final VersionFileModel? file;

  const SongVersionModel({
    required this.version_number,
    required this.lyrics,
    required this.timestamp,
    required this.file,
  });

  @override
  List<Object?> get props => [version_number, lyrics, timestamp, file];
}
