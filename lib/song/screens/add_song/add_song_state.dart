import 'package:band_space/project/repository/project_repository.dart';
import 'package:flutter/material.dart';

import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/song_state.dart';

class AddSongState with ChangeNotifier {
  AddSongState(this.projectRepository);

  final ProjectRepository projectRepository;

  SongUploadFile? _selectedFile;
  bool _addingSong = false;
  SongState? _state;

  SongUploadFile? get selectedFile => _selectedFile;
  bool get addingSong => _addingSong;
  SongState? get songState => _state;

  bool get canPop => !_addingSong;

  Future<void> onFileSelected(SongUploadFile file) async {
    _selectedFile = file;

    notifyListeners();
  }

  void onSongStateSelected(SongState state) {
    _state = state;

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
          state: _state ?? SongState.draft, // TODO: dodać walidacje
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
