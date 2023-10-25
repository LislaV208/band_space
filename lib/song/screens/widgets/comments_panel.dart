import 'package:flutter/material.dart';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/song/screens/widgets/comment_tile.dart';
import 'package:band_space/widgets/app_stream_builder.dart';

class CommentsPanel extends StatefulWidget {
  const CommentsPanel({
    super.key,
    required this.commentsStream,
    required this.onSelectedCommentChange,
  });

  final Stream<List<VersionComment>> commentsStream;
  final void Function(VersionComment? comment) onSelectedCommentChange;

  @override
  State<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  VersionComment? _selectedComment;

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
      child: AppStreamBuilder(
        stream: widget.commentsStream,
        noDataWidget: Column(
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
        ),
        builder: (context, comments) {
          return ImplicitlyAnimatedList(
            items: comments,
            areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
            itemBuilder: (context, animation, comment, index) {
              return SizeFadeTransition(
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                animation: animation,
                child: CommentTile(
                  comment: comment,
                  onTap: () => setState(
                    () {
                      if (_selectedComment == null || _selectedComment != comment) {
                        _selectedComment = comment;
                      } else {
                        _selectedComment = null;
                      }

                      widget.onSelectedCommentChange(_selectedComment);
                    },
                  ),
                  onEdit: () {},
                  onDelete: () {
                    context.read<VersionRepository>().deleteComment(comment.id);
                  },
                  isSelected: comment == _selectedComment,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
