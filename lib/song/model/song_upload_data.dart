import 'dart:typed_data';

class SongUploadData {
  final String title;
  final SongUploadFile file;

  const SongUploadData({
    required this.title,
    required this.file,
  });
}

class SongUploadFile {
  final String name;
  final String extension;
  final Uint8List data;
  final int size;
  final String mimeType;

  const SongUploadFile({
    required this.name,
    required this.extension,
    required this.data,
    required this.size,
    required this.mimeType,
  });
}
