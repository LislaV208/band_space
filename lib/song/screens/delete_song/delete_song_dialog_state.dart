import 'package:band_space/song/model/song.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:flutter/material.dart';

class DeleteSongDialogState with ChangeNotifier {
  DeleteSongDialogState(this.songRepository);

  final SongRepository songRepository;

  bool _deleteInProgress = false;

  bool get deleteInProgress => _deleteInProgress;

  Future<bool> deleteSong(Song song) async {
    _deleteInProgress = true;
    notifyListeners();

    var isFail = false;

    try {
      await songRepository.deleteSong(song);
    } on Exception catch (_) {
      isFail = true;
    }

    _deleteInProgress = false;
    notifyListeners();

    return !isFail;
  }
}
