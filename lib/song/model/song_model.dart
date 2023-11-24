// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import 'package:band_space/user/model/user_model.dart';
import 'package:band_space/utils/file_size.dart';

class SongModel extends Equatable {
  final String id;
  final String current_version_id;
  final DateTime? created_at;
  final String title;
  final int comments_count;
  final FileSize? size;
  final UserModel? uploader;
  final bool upload_in_progress;

  const SongModel({
    required this.id,
    required this.current_version_id,
    required this.created_at,
    required this.title,
    required this.comments_count,
    required this.size,
    required this.uploader,
    required this.upload_in_progress,
  });

  @override
  List<Object?> get props => [id];
}
