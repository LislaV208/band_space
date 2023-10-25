import 'package:flutter/material.dart';

import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/widgets/app_stream_builder.dart';
import 'package:band_space/widgets/hover_widget.dart';

class TimelineCommentMarkers extends StatelessWidget {
  const TimelineCommentMarkers({
    super.key,
    required this.commentsStream,
    required this.selectedComment,
    required this.songDuration,
    required this.maxWidth,
    required this.onSelectedCommentChange,
  });

  final Stream<List<VersionComment>> commentsStream;
  final VersionComment? selectedComment;
  final Duration songDuration;
  final double maxWidth;
  final void Function(VersionComment? comment) onSelectedCommentChange;

  @override
  Widget build(BuildContext context) {
    const paddingValue = 10.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(paddingValue, 4, paddingValue, 0),
      child: AppStreamBuilder(
        stream: commentsStream,
        showEmptyDataText: false,
        loadingWidget: const SizedBox(),
        errorWidget: const SizedBox(),
        builder: (context, comments) {
          return Stack(
            children: comments.map(
              (comment) {
                final position = comment.start_position;
                if (position == null) return const SizedBox();

                final isSelected = comment == selectedComment;

                return Padding(
                  padding: EdgeInsets.only(left: position.inMilliseconds / songDuration.inMilliseconds * maxWidth),
                  child: HoverWidget(
                    builder: (context, isHovered) {
                      return GestureDetector(
                        onTap: () {
                          onSelectedCommentChange(isSelected ? null : comment);
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: isSelected ? Colors.white : Colors.black,
                          child: CircleAvatar(
                            radius: 9,
                            child: Text(
                              comment.author.characters.first.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}
