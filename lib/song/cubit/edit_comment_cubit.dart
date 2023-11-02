import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/cubit/edit_comment_state.dart';
import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/song/repository/version_repository.dart';

class EditCommentCubit extends Cubit<EditCommentState> {
  final VersionRepository versionRepository;

  EditCommentCubit({
    required this.versionRepository,
  }) : super(const EditCommentState());

  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  void startEditing(VersionComment comment) {
    textEditingController.text = comment.text;

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });

    emit(EditCommentState(
      comment: comment,
      position: comment.start_position,
      usePosition: comment.start_position != null,
    ));
  }

  void onPositionSwitchChanged(bool usePosition) {
    emit(state.copyWithUsePosition(usePosition));
  }

  void onPositionChange(Duration? position) {
    emit(state.copyWithPosition(position));
  }

  void cancelEditing() {
    emit(const EditCommentState());
  }

  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
  }
}
