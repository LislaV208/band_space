// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import 'package:band_space/user/model/user_model.dart';

class VersionComment extends Equatable {
  final String id;
  final DateTime? created_at;
  final UserModel? author;
  final String text;
  final Duration? start_position;

  const VersionComment({
    required this.id,
    required this.created_at,
    required this.author,
    required this.text,
    required this.start_position,
  });

  @override
  List<Object?> get props => [id, created_at, author, text, start_position];
}
