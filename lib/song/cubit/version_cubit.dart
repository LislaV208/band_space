import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/song/repository/version_repository.dart';

class VersionCubit extends Cubit<VersionState> {
  VersionCubit(
    super.initialState, {
    required this.currentVersion,
    required this.versionRepository,
    required this.audioPlayer,
  }) {
    if (currentVersion.file != null) {
      audioPlayer.setUrl(currentVersion.file!.download_url);
    }

    stream.listen((event) {
      print(event);
    });
  }

  final SongVersionModel currentVersion;
  final VersionRepository versionRepository;
  final AudioPlayerService audioPlayer;

  void onKeyPressed(RawKeyEvent event, FocusNode commentFocusNode) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      commentFocusNode.requestFocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      commentFocusNode.unfocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
      if (!commentFocusNode.hasFocus) {
        audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play();
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      if (!commentFocusNode.hasFocus) {
        audioPlayer.rewind();
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      if (!commentFocusNode.hasFocus) {
        audioPlayer.forward();
      }
    }
  }

  void onCommentTap(VersionComment comment) {
    final newSelectedComment = comment == state.selectedComment ? null : comment;

    if (newSelectedComment?.start_position != null) {
      audioPlayer.seek(newSelectedComment!.start_position!);
    }

    emit(VersionState(selectedComment: newSelectedComment));
  }

  void addComment(
    String text, {
    required Duration? startPosition,
    required Duration? endPosition,
  }) {
    versionRepository.addComment(text, startPosition, endPosition);
  }

  void editComment() {}

  void deleteComment(VersionComment comment) {
    versionRepository.deleteComment(comment.id);
  }

  void dispose() {
    audioPlayer.dispose();
  }
}
