// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:equatable/equatable.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.created_at,
  });

  final String id;
  final String name;
  final DateTime created_at;

  @override
  List<Object> get props => [id, name, created_at];

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      created_at: DateTime.parse(map['created_at']).toLocal(),
    );
  }

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source));
}
