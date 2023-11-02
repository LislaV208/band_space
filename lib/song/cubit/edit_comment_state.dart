import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_comment.dart';

class EditCommentState extends Equatable {
  final VersionComment? comment;
  final Duration? position;
  final bool usePosition;

  const EditCommentState({
    this.comment,
    this.position,
    this.usePosition = false,
  });

  EditCommentState copyWithComment(VersionComment? comment) =>
      EditCommentState(comment: comment, position: position, usePosition: usePosition);
  EditCommentState copyWithPosition(Duration? position) =>
      EditCommentState(comment: comment, position: position, usePosition: usePosition);
  EditCommentState copyWithUsePosition(bool usePosition) =>
      EditCommentState(comment: comment, position: position, usePosition: usePosition);

  @override
  List<Object?> get props => [comment, position, usePosition];
}
