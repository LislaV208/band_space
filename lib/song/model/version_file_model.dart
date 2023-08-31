// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

class VersionFileModel extends Equatable {
  final String original_name;
  final String storage_name;
  final int size;
  final int duration;
  final String mime_type;
  final String download_url;

  const VersionFileModel({
    required this.original_name,
    required this.storage_name,
    required this.size,
    required this.duration,
    required this.mime_type,
    required this.download_url,
  });

  @override
  List<Object> get props {
    return [
      original_name,
      storage_name,
      size,
      duration,
      mime_type,
      download_url,
    ];
  }

  factory VersionFileModel.fromMap(Map<String, dynamic> map) {
    return VersionFileModel(
      original_name: map['original_name'] ?? '',
      storage_name: map['storage_name'] ?? '',
      size: map['size'] ?? 0,
      duration: map['duration'] ?? 0,
      mime_type: map['mime_type'] ?? '',
      download_url: map['download_url'] ?? '',
    );
  }
}
