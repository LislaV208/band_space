// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class SongModel extends Equatable {
  final String id;
  final DateTime created_at;
  final String title;
  final int? tempo;

  const SongModel({
    required this.id,
    required this.created_at,
    required this.title,
    required this.tempo,
  });

  @override
  List<Object?> get props => [id, created_at, title, tempo];
}
