import 'package:band_space/song/repository/song_repository.dart';
import 'package:flutter/material.dart';

class DeleteSongDialogState with ChangeNotifier {
  DeleteSongDialogState(this.songRepository);

  final SongRepository songRepository;

  bool _deleteInProgress = false;

  bool get deleteInProgress => _deleteInProgress;

  Future<bool> deleteSong() async {
    _deleteInProgress = true;
    notifyListeners();

    var isFail = false;

    try {
      await songRepository.delete();
    } on Exception catch (_) {
      isFail = true;
    }

    _deleteInProgress = false;
    notifyListeners();

    return !isFail;
  }
}
