import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/song/screens/widgets/comments_panel.dart';
import 'package:band_space/song/screens/widgets/version_comment_input.dart';
import 'package:band_space/song/widgets/song_player.dart';

class VersionView extends StatefulWidget {
  const VersionView({super.key});

  @override
  State<VersionView> createState() => _VersionViewState();
}

class _VersionViewState extends State<VersionView> {
  final _audioPlayer = sl<AudioPlayerService>();
  late final _currentVersion = context.read<SongVersionModel>();

  final _commentFocusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (_currentVersion.file != null) {
      _audioPlayer.setUrl(_currentVersion.file!.download_url);
    }

    _commentFocusNode.addListener(() {
      if (!_commentFocusNode.hasFocus) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _commentFocusNode.dispose();
    _keyboardFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: _keyboardFocusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          _commentFocusNode.requestFocus();
        } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
          _commentFocusNode.unfocus();
        } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          if (!_commentFocusNode.hasFocus) {
            _audioPlayer.isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
          }
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          if (!_commentFocusNode.hasFocus) {
            _audioPlayer.rewind();
          }
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          if (!_commentFocusNode.hasFocus) {
            _audioPlayer.forward();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SongPlayer(
                      audioPlayer: _audioPlayer,
                      duration: _currentVersion.file!.duration,
                      markersStream: context.read<VersionRepository>().getMarkers(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  VersionCommentInput(
                    focusNode: _commentFocusNode,
                    getCurrentPosition: () => _audioPlayer.currentPosition,
                    onSubmitted: (value, startPosition, endPosition) {
                      context.read<VersionRepository>().addComment(value, startPosition, endPosition);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            CommentsPanel(
              onCommentSelected: (comment) {
                if (comment.start_position != null) {
                  _audioPlayer.seek(comment.start_position!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
