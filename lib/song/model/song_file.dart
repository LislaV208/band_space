// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:equatable/equatable.dart';

class SongFile extends Equatable {
  final String name;
  final int size;
  final String mime_type;
  final String storage_path;
  final String download_url;

  const SongFile({
    required this.name,
    required this.size,
    required this.mime_type,
    required this.storage_path,
    required this.download_url,
  });

  @override
  List<Object> get props {
    return [
      name,
      size,
      mime_type,
      storage_path,
      download_url,
    ];
  }

  factory SongFile.fromMap(Map<String, dynamic> map) {
    return SongFile(
      name: map['name'] ?? '',
      size: map['size']?.toInt() ?? 0,
      mime_type: map['mime_type'] ?? '',
      storage_path: map['storage_path'] ?? '',
      download_url: map['download_url'] ?? '',
    );
  }

  factory SongFile.fromJson(String source) =>
      SongFile.fromMap(json.decode(source));
}
