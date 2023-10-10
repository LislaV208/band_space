// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class Marker extends Equatable {
  final String id;
  final String name;
  final int start_position;
  final int? end_position;

  const Marker({
    required this.id,
    required this.name,
    required this.start_position,
    required this.end_position,
  });

  @override
  List<Object?> get props => [id];
}
