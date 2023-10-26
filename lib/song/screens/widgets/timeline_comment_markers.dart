import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/widgets/app_stream_builder.dart';
import 'package:band_space/widgets/hover_widget.dart';

class TimelineCommentMarkers extends StatelessWidget {
  const TimelineCommentMarkers({
    super.key,
    required this.maxWidth,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    const paddingValue = 10.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(paddingValue, 4, paddingValue, 0),
      child: AppStreamBuilder(
        stream: context.read<VersionCubit>().versionRepository.getComments(),
        showEmptyDataText: false,
        loadingWidget: const SizedBox(),
        errorWidget: const SizedBox(),
        builder: (context, comments) {
          final songDuration = context.select((VersionCubit cubit) => cubit.currentVersion.file!.duration);

          return Stack(
            children: comments.map(
              (comment) {
                final position = comment.start_position;
                if (position == null) return const SizedBox();

                return Padding(
                  key: ValueKey(comment.id),
                  padding: EdgeInsets.only(left: position.inMilliseconds / songDuration.inMilliseconds * maxWidth),
                  child: HoverWidget(
                    builder: (context, isHovered) {
                      return GestureDetector(
                        onTap: () => context
                            .read<VersionCubit>()
                            .onCommentTap(CommentTapSource.marker, comments.indexOf(comment), comment),
                        child: BlocSelector<VersionCubit, VersionState, bool>(
                          selector: (state) => state.selectedComment == comment,
                          builder: (context, isSelected) {
                            return CircleAvatar(
                              radius: 10,
                              backgroundColor: isSelected ? Colors.white : Colors.black,
                              child: CircleAvatar(
                                radius: 9,
                                child: Text(
                                  comment.author.characters.first.toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
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
