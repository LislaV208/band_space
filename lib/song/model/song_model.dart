// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import 'package:band_space/song/song_state.dart';

class SongModel extends Equatable {
  final String id;
  final DateTime created_at;
  final String title;
  final SongState state;

  const SongModel({
    required this.id,
    required this.created_at,
    required this.title,
    required this.state,
  });

  @override
  List<Object?> get props => [id, created_at, title, state];
}
