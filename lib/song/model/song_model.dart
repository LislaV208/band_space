// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class SongModel extends Equatable {
  final String id;
  final DateTime? created_at;
  final String title;
  final String current_version_id;
  final bool upload_in_progress;

  const SongModel({
    required this.id,
    required this.created_at,
    required this.title,
    required this.current_version_id,
    required this.upload_in_progress,
  });

  @override
  List<Object?> get props => [id];
}
