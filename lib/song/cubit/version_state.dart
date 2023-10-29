import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_comment.dart';

class VersionState extends Equatable {
  final List<VersionComment>? comments;
  final VersionComment? selectedComment;
  final dynamic error;

  const VersionState({this.comments, this.selectedComment, this.error});

  VersionState setComments(List<VersionComment> comments) {
    return VersionState(comments: comments, selectedComment: selectedComment);
  }

  VersionState setSelectedComment(VersionComment? selectedComment) {
    return VersionState(comments: comments, selectedComment: selectedComment);
  }

  VersionState setError(dynamic error) {
    return VersionState(error: error);
  }

  @override
  List<Object?> get props => [comments, selectedComment, error];
}
