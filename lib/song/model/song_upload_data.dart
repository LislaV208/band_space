import 'dart:typed_data';

import 'package:band_space/song/song_state.dart';

class SongUploadData {
  final String title;
  final SongUploadFile? file;
  final SongState state;

  const SongUploadData({
    required this.title,
    required this.file,
    required this.state,
  });
}

class SongUploadFile {
  final String name;
  final String extension;
  final Uint8List data;
  final int size;
  final String mimeType;
  final int duration;

  const SongUploadFile({
    required this.name,
    required this.extension,
    required this.data,
    required this.size,
    required this.mimeType,
    required this.duration,
  });
}
