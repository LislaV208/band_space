import 'package:flutter/material.dart';

import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/song/model/song_upload_data.dart';

class AddSongState with ChangeNotifier {
  AddSongState(this.projectRepository);

  final ProjectRepository projectRepository;

  SongUploadFile? _selectedFile;
  bool _addingSong = false;

  SongUploadFile? get selectedFile => _selectedFile;
  bool get addingSong => _addingSong;

  bool get canPop => !_addingSong;

  Future<void> onFileSelected(SongUploadFile file) async {
    _selectedFile = file;

    notifyListeners();
  }

  Future<String?> addSong(
    String title,
  ) async {
    _addingSong = true;
    notifyListeners();

    String? songId;

    try {
      songId = await projectRepository.addSong(
        SongUploadData(
          title: title,
          file: _selectedFile,
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
