// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.created_at,
  });

  final String id;
  final String name;
  final DateTime? created_at;

  @override
  List<Object?> get props => [id];
}
