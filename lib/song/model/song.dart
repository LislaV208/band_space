// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String project_id;
  final String title;
  final DateTime created_at;
  final DateTime modified_at;

  const Song({
    required this.id,
    required this.project_id,
    required this.title,
    required this.created_at,
    required this.modified_at,
  });

  @override
  List<Object> get props => [id, title, created_at, modified_at];

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      project_id: map['project_id'] ?? '',
      title: map['title'] ?? '',
      created_at: DateTime.parse(map['created_at']).toLocal(),
      modified_at: DateTime.parse(map['modified_at']).toLocal(),
    );
  }

  factory Song.fromJson(String source) => Song.fromMap(json.decode(source));
}
