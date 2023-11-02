import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:band_space/song/cubit/edit_comment_cubit.dart';
import 'package:band_space/song/cubit/edit_comment_state.dart';
import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/song/screens/widgets/comment_position_switch.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_alert_dialog.dart';
import 'package:band_space/widgets/elapsed_time_text.dart';
import 'package:band_space/widgets/hover_widget.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.index,
    required this.comment,
  });

  final int index;
  final VersionComment comment;

  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 300);
    const animationCurve = Curves.fastOutSlowIn;

    return BlocSelector<EditCommentCubit, EditCommentState, bool>(
      selector: (state) => state.comment == comment,
      builder: (context, isInEdit) {
        if (isInEdit) {
          return const _CommentInEditTile();
        }

        return HoverWidget(
          showCursor: comment.start_position != null,
          builder: (context, isHovered) {
            return GestureDetector(
              onTap: () {
                context.read<EditCommentCubit>().cancelEditing();
                context.read<VersionCubit>().onCommentTap(CommentTapSource.listItem, comment);
              },
              child: BlocSelector<VersionCubit, VersionState, bool>(
                selector: (state) => state.selectedComment == comment,
                builder: (context, isSelected) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueGrey.shade900.withOpacity(0.3)
                          : isHovered
                              ? Colors.blueGrey.shade900.withOpacity(0.8)
                              : Colors.blueGrey.shade900.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(
                              width: 2.0,
                              color: Colors.blue[300]!.withOpacity(0.6),
                            )
                          : null,
                    ),
                    padding: EdgeInsets.all(16.0 - (isSelected ? 2.0 : 0.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  child: Text(comment.author.characters.first.toUpperCase()),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  comment.author,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Tooltip(
                                    preferBelow: false,
                                    verticalOffset: 14.0,
                                    message: DateFormat('dd/MM/yyyy HH:mm:ss').format(comment.created_at!),
                                    child: comment.created_at != null
                                        ? ElapsedTimeText(dateFrom: comment.created_at!)
                                        : const SizedBox(),
                                  ),
                                ),
                              ],
                            ),
                            AnimatedOpacity(
                              opacity: isHovered ? 1.0 : 0.0,
                              duration: animationDuration,
                              curve: animationCurve,
                              child: AnimatedSlide(
                                offset: Offset(isHovered ? 0.0 : 0.3, 0),
                                duration: animationDuration,
                                curve: animationCurve,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        context.read<EditCommentCubit>().startEditing(comment);
                                        if (!isSelected) {
                                          context.read<VersionCubit>().onCommentTap(CommentTapSource.listItem, comment);
                                        } else if (comment.start_position != null) {
                                          context.read<VersionCubit>().audioPlayer.seek(comment.start_position!);
                                        }
                                      },
                                      icon: const Icon(Icons.edit),
                                      iconSize: 16,
                                      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                      tooltip: 'Edytuj',
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final cubit = context.read<VersionCubit>();
                                        final deleteConfirmed = await context.showDialog<bool>(
                                              dialog: const AppAlertDialog(
                                                title: 'Usuń komentarz',
                                                content: 'Czy chcesz usunąć komentarz?',
                                                confirmText: 'Usuń',
                                                iconData: Icons.delete,
                                              ),
                                            ) ??
                                            false;

                                        if (deleteConfirmed) {
                                          cubit.deleteComment(comment);
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      iconSize: 16,
                                      visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                      tooltip: 'Usuń',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        comment.start_position == null
                            ? SelectableText(comment.text)
                            : RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${comment.start_position!.format()}  ',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.inversePrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: comment.text),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _CommentInEditTile extends StatefulWidget {
  const _CommentInEditTile({
    super.key,
  });

  @override
  State<_CommentInEditTile> createState() => _CommentInEditTileState();
}

class _CommentInEditTileState extends State<_CommentInEditTile> {
  @override
  Widget build(BuildContext context) {
    final comment = context.read<EditCommentCubit>().state.comment!;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 2.0,
          color: Colors.blue[300]!.withOpacity(0.6),
        ),
      ),
      padding: const EdgeInsets.all(16.0 - 2.0), // -2 bo border
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    child: Text(comment.author.characters.first.toUpperCase()),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    comment.author,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Tooltip(
                      preferBelow: false,
                      verticalOffset: 14.0,
                      message: DateFormat('dd/MM/yyyy HH:mm:ss').format(comment.created_at!),
                      child: comment.created_at != null
                          ? ElapsedTimeText(dateFrom: comment.created_at!)
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (isFocused) {
              if (!isFocused) {
                context.read<VersionCubit>().keyboardFocusNode.requestFocus();
              }
            },
            child: TextField(
              autofocus: true,
              focusNode: context.read<EditCommentCubit>().focusNode,
              controller: context.read<EditCommentCubit>().textEditingController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                hoverColor: Colors.transparent,
                border: MaterialStateOutlineInputBorder.resolveWith(
                  (states) => OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue[300]!.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocSelector<EditCommentCubit, EditCommentState, Duration?>(
                  selector: (state) => state.position,
                  builder: (context, position) {
                    return CommentPositionSwitch(
                      initialValue: comment.start_position != null,
                      position: position ?? context.read<VersionCubit>().audioPlayer.currentPosition,
                      // position: context.read<VersionCubit>().audioPlayer.currentPosition,
                      onChanged: (isChecked) {
                        context.read<EditCommentCubit>().onPositionSwitchChanged(isChecked);
                      },
                    );
                  }),
              ButtonBar(
                buttonPadding: EdgeInsets.zero,
                children: [
                  TextButton(
                    onPressed: () {
                      if (comment.start_position == null) {
                        context.read<VersionCubit>().onCommentTap(CommentTapSource.listItem, comment);
                      } else {
                        context.read<VersionCubit>().audioPlayer.seek(comment.start_position!);
                      }
                      context.read<EditCommentCubit>().cancelEditing();
                    },
                    child: const Text(
                      'Anuluj',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<VersionCubit>().editComment();
                    },
                    child: Text('Zapisz'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
