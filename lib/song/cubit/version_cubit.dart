import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/song/cubit/edit_comment_cubit.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/song/repository/version_repository.dart';

enum CommentTapSource {
  marker,
  listItem,
}

class VersionCubit extends Cubit<VersionState> {
  final SongVersionModel currentVersion;
  final VersionRepository versionRepository;
  final AudioPlayerService audioPlayer;
  final EditCommentCubit editCommentCubit;

  final commentsListScrollController = ItemScrollController();
  final commentsListPositionsListener = ItemPositionsListener.create();
  final keyboardFocusNode = FocusNode();

  VersionCubit({
    required this.editCommentCubit,
    required this.currentVersion,
    required this.versionRepository,
    required this.audioPlayer,
  }) : super(const VersionState()) {
    if (currentVersion.file != null) {
      audioPlayer.setUrl(currentVersion.file!.download_url);
    }

    stream.listen((event) {
      print(event);
    });

    _commentsSub = versionRepository.getComments().listen((comments) {
      comments.sort(
        (a, b) {
          final aPos = a.start_position != null ? a.start_position!.inMilliseconds : -1;
          final bPos = b.start_position != null ? b.start_position!.inMilliseconds : -1;

          return aPos - bPos;
        },
      );
      emit(state.setComments(comments));
    })
      ..onError((e) {
        emit(state.setError(e));
      });
  }

  StreamSubscription<List<VersionComment>>? _commentsSub;

  void onKeyPressed(RawKeyEvent event, FocusNode commentFocusNode) {
    if (editCommentCubit.state.comment != null) {
      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
        editComment();
      } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
        editCommentCubit.cancelEditing();
      }

      return;
    }

    if (!commentFocusNode.hasFocus && state.selectedComment != null) {
      if (event.isKeyPressed(LogicalKeyboardKey.keyE)) {
        if (editCommentCubit.state.comment != null) {
          editCommentCubit.focusNode.requestFocus();
        } else {
          editCommentCubit.startEditing(state.selectedComment!);
        }
      }
    }

    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      commentFocusNode.requestFocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      commentFocusNode.unfocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
      if (!commentFocusNode.hasFocus) {
        onSongPlayPause();
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

  void onSongPlayPause() {
    if (audioPlayer.isPlaying) {
      audioPlayer.pause();

      editCommentCubit.onPositionChange(audioPlayer.currentPosition);
    } else {
      audioPlayer.play();

      emit(state.setSelectedComment(null));
    }
  }

  void onCommentTap(CommentTapSource tapSource, VersionComment comment) {
    if (comment.start_position == null && editCommentCubit.state.comment == null) return;

    final newSelectedComment = comment == state.selectedComment ? null : comment;

    if (newSelectedComment?.start_position != null) {
      audioPlayer.pause();
      audioPlayer.seek(newSelectedComment!.start_position!);
    }

    emit(state.setSelectedComment(newSelectedComment));

    if (newSelectedComment == null) return;

    final index = state.comments?.indexOf(newSelectedComment) ?? -1;
    if (index < 0) return;

    if (tapSource == CommentTapSource.marker) {
      commentsListScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn,
      );
    } else if (tapSource == CommentTapSource.listItem) {
      final itemPosition = commentsListPositionsListener.itemPositions.value.firstWhereOrNull(
        (ItemPosition position) => position.index == index,
      );

      if (itemPosition != null) {
        // Check if the item is fully visible
        if (itemPosition.itemLeadingEdge >= 0 && itemPosition.itemTrailingEdge <= 1) {
          // The item is fully visible
          return;
        }
      }

      commentsListScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastOutSlowIn,
        alignment: 0.5,
      );
    }
  }

  void addComment(
    String text, {
    required Duration? startPosition,
    required Duration? endPosition,
  }) async {
    final newComment = await versionRepository.addComment(text, startPosition, endPosition);

    final index = state.comments?.indexOf(newComment) ?? -1;

    if (index >= 0) {
      commentsListScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastOutSlowIn,
        alignment: 0.5,
      );
    }
  }

  void editComment() async {
    final text = editCommentCubit.textEditingController.text;
    final editState = editCommentCubit.state;

    editCommentCubit.cancelEditing();

    // nic nie robimy jezeli nic sie nie zmienilo
    if (text == editState.comment?.text &&
        (editState.comment?.start_position != null) == editState.usePosition &&
        editState.position == editState.comment?.start_position) {
      return;
    }

    final editedComment = await versionRepository.editComment(
        editState.comment!.id, text, editState.usePosition ? editState.position : null, null);
    emit(state.setSelectedComment(editedComment));
  }

  void deleteComment(VersionComment comment) {
    versionRepository.deleteComment(comment.id);
  }

  void dispose() {
    _commentsSub?.cancel();

    audioPlayer.dispose();
    keyboardFocusNode.dispose();
  }
}
