import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/cubit/edit_comment_cubit.dart';
import 'package:band_space/song/cubit/edit_comment_state.dart';
import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/widgets/hover_widget.dart';

class TimelineCommentMarkers extends StatefulWidget {
  const TimelineCommentMarkers({
    super.key,
    required this.maxWidth,
  });

  final double maxWidth;

  @override
  State<TimelineCommentMarkers> createState() => _TimelineCommentMarkersState();
}

class _TimelineCommentMarkersState extends State<TimelineCommentMarkers> {
  VersionComment? _hoveredComment;

  @override
  Widget build(BuildContext context) {
    const paddingValue = 10.0;
    final songDuration = context.select((VersionCubit cubit) => cubit.currentVersion.file!.duration);

    return Padding(
      padding: const EdgeInsets.fromLTRB(paddingValue, 4, paddingValue, 0),
      child: BlocSelector<EditCommentCubit, EditCommentState, VersionComment?>(
        selector: (state) => state.comment,
        builder: (context, commentInEdit) {
          return BlocBuilder<VersionCubit, VersionState>(
            builder: (context, state) {
              if (state.comments == null) {
                return const SizedBox();
              }

              final comments = state.comments!;
              final selectedComment = state.selectedComment ?? commentInEdit;

              final selectedOrHoveredComment = _hoveredComment ?? selectedComment;

              // jezeli komentarz jest zaznaczony, to usuwamy go z listy i dodajemy, aby znalazł się
              // na końcu listy, aby został wyrenderowany jako ostatni
              // w przeciwnym razie zostawiamy listę taka jaka jest
              final positionedComments = selectedOrHoveredComment == null
                  ? comments
                  : ([...comments]
                    ..removeWhere((comment) => comment.id == selectedOrHoveredComment.id)
                    ..add(selectedOrHoveredComment));

              // final positionedComments = comments;

              return Stack(
                children: positionedComments.map(
                  // children: comments.map(
                  (comment) {
                    final position = comment.start_position;
                    if (position == null) return const SizedBox();

                    return Padding(
                      key: ValueKey(comment.id),
                      padding: EdgeInsets.only(
                          left: position.inMilliseconds / songDuration.inMilliseconds * widget.maxWidth),
                      child: HoverWidget(
                        onHoverEnter: () {
                          setState(() {
                            _hoveredComment = comment;
                          });
                        },
                        onHoverExit: () {
                          setState(() {
                            _hoveredComment = null;
                          });
                        },
                        builder: (context, _) {
                          return GestureDetector(
                            onTap: () {
                              if (comment != context.read<EditCommentCubit>().state.comment) {
                                context.read<VersionCubit>().onCommentTap(CommentTapSource.marker, comment);
                                context.read<EditCommentCubit>().cancelEditing();
                              }
                            },
                            child: _CommentMarker(
                              author: comment.author?.displayName ?? '?',
                              isSelected: _hoveredComment == comment || selectedComment == comment,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class _CommentMarker extends StatelessWidget {
  const _CommentMarker({
    // super.key,
    required this.author,
    required this.isSelected,
  });

  final String author;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: isSelected ? Colors.white : Colors.black,
      child: CircleAvatar(
        radius: 9,
        child: Text(
          author.characters.first.toUpperCase(),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
