// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:equatable/equatable.dart';

class VersionFileModel extends Equatable {
  final String name;
  final String storage_path;
  final int size;
  final Duration duration;
  final String mime_type;
  final String download_url;

  const VersionFileModel({
    required this.name,
    required this.storage_path,
    required this.size,
    required this.duration,
    required this.mime_type,
    required this.download_url,
  });

  @override
  List<Object> get props {
    return [
      name,
      storage_path,
      size,
      duration,
      mime_type,
      download_url,
    ];
  }

  factory VersionFileModel.fromMap(Map<String, dynamic> map) {
    return VersionFileModel(
      name: map['name'] ?? '',
      storage_path: map['storage_path'] ?? '',
      size: map['size']?.toInt() ?? 0,
      duration: Duration(milliseconds: map['duration']?.toInt() ?? 0),
      mime_type: map['mime_type'] ?? '',
      download_url: map['download_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'storage_path': storage_path,
      'size': size,
      'duration': duration.inMilliseconds,
      'mime_type': mime_type,
      'download_url': download_url,
    };
  }

  String toJson() => json.encode(toMap());

  factory VersionFileModel.fromJson(String source) => VersionFileModel.fromMap(json.decode(source));
}
