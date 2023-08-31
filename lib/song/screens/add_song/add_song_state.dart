import 'package:audioplayers/audioplayers.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class AddSongState with ChangeNotifier {
  AddSongState(this.songRepository);

  final SongRepository songRepository;

  PlatformFile? _selectedFile;
  bool _openingFilePicker = false;
  bool _addingSong = false;

  PlatformFile? get selectedFile => _selectedFile;
  bool get openingFilePicker => _openingFilePicker;
  bool get addingSong => _addingSong;

  bool get canPop => !_openingFilePicker && !_addingSong;

  Future<void> selectFile() async {
    _openingFilePicker = true;
    notifyListeners();

    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.audio,
      initialDirectory: _selectedFile != null ? _selectedFile!.path : null,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      _selectedFile = file;
    }

    _openingFilePicker = false;
    notifyListeners();
  }

  Future<String?> addSong(
    String projectId,
    String title,
    String tempo,
  ) async {
    _addingSong = true;
    notifyListeners();

    String? songId;
    SongUploadFile? uploadFile;

    if (_selectedFile != null) {
      final path = _selectedFile?.path;

      if (path != null) {
        final player = AudioPlayer();
        await player.setSourceDeviceFile(path);
        final duration = await player.getDuration();

        final mimeType = lookupMimeType(path);

        uploadFile = SongUploadFile(
          name: _selectedFile!.name,
          extension: _selectedFile!.extension ?? '',
          data: _selectedFile!.bytes!,
          size: _selectedFile!.size,
          mimeType: mimeType!,
          duration: duration!.inSeconds,
        );
      }
    }

    try {
      songId = await songRepository.addSong(
        projectId,
        SongUploadData(
          title: title,
          tempo: tempo.isNotEmpty ? tempo : null,
          file: uploadFile,
        ),
      );
    } on Exception catch (_) {
      // do nothing
    }

    _addingSong = false;
    notifyListeners();

    return songId;
  }
}
