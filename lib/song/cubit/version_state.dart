import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/version_comment.dart';

class VersionState extends Equatable {
  final VersionComment? selectedComment;

  const VersionState({
    required this.selectedComment,
  });

  @override
  List<Object?> get props => [selectedComment];
}
