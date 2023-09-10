// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import 'package:band_space/user/model/user_model.dart';

class ProjectModel extends Equatable {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.created_at,
    required this.created_by,
    required this.owners,
  });

  final String id;
  final String name;
  final DateTime? created_at;
  final UserModel created_by;
  final List<UserModel> owners;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      created_at,
      created_by,
      owners,
    ];
  }
}
