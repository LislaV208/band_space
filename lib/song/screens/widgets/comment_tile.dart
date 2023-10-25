import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_alert_dialog.dart';
import 'package:band_space/widgets/elapsed_time_text.dart';
import 'package:band_space/widgets/hover_widget.dart';

class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.isSelected = false,
  });

  final VersionComment comment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 300);
    const animationCurve = Curves.fastOutSlowIn;

    return HoverWidget(
      builder: (context, isHovered) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Colors.blueGrey.shade900.withOpacity(0.3)
                  : isHovered
                      ? Colors.blueGrey.shade900.withOpacity(0.8)
                      : Colors.blueGrey.shade900.withOpacity(0.45),
              borderRadius: BorderRadius.circular(14),
              border: widget.isSelected
                  ? Border.all(
                      width: 2.0,
                      color: Colors.blue[300]!.withOpacity(0.6),
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0 - (widget.isSelected ? 2.0 : 0.0)),
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
                            child: Text(widget.comment.author.characters.first.toUpperCase()),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.comment.author,
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
                              message: DateFormat('dd/MM/yyyy HH:mm:ss').format(widget.comment.created_at!),
                              child: widget.comment.created_at != null
                                  ? ElapsedTimeText(dateFrom: widget.comment.created_at!)
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
                                onPressed: () {},
                                icon: const Icon(Icons.edit),
                                iconSize: 16,
                                visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                tooltip: 'Edytuj',
                              ),
                              IconButton(
                                onPressed: () async {
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
                                    widget.onDelete();
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
                  Row(
                    children: [
                      if (widget.comment.start_position != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(
                            widget.comment.start_position!.format(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          widget.comment.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
