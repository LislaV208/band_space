import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/song/screens/widgets/comment_tile.dart';

class CommentsPanel extends StatefulWidget {
  const CommentsPanel({super.key});

  @override
  State<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  final listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BlocBuilder<VersionCubit, VersionState>(
        builder: (context, state) {
          if (state.error != null) {
            return Center(
              child: Text(state.error.toString()),
            );
          }

          if (state.comments == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final comments = state.comments!;

          if (comments.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 70,
                  color: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Text(
                    'Rozpocznij dyskuję na temat utworu dodając komentarz',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ),
              ],
            );
          }

          // TODO: make list animated again!
          return ScrollablePositionedList.builder(
            physics: const ClampingScrollPhysics(),
            itemScrollController: context.read<VersionCubit>().commentsListScrollController,
            itemPositionsListener: context.read<VersionCubit>().commentsListPositionsListener,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return CommentTile(
                key: ValueKey(comments[index].id),
                index: index,
                comment: comments[index],
              );
            },
          );
        },
      ),
    );
  }
}
