// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import 'package:band_space/user/model/personal_data.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final PersonalData? personal_data;

  const UserModel({
    required this.id,
    required this.email,
    required this.personal_data,
  });

  String get fullName => personal_data?.fullName ?? email;
  String get displayName => personal_data?.displayName ?? email;

  @override
  List<Object> get props => [id, email];
}
