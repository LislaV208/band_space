import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/cubit/edit_comment_cubit.dart';
import 'package:band_space/song/cubit/edit_comment_state.dart';
import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/screens/widgets/comment_position_switch.dart';

class VersionCommentInput extends StatefulWidget {
  const VersionCommentInput({
    super.key,
    this.focusNode,
  });

  final FocusNode? focusNode;

  @override
  State<VersionCommentInput> createState() => _VersionCommentInputState();
}

class _VersionCommentInputState extends State<VersionCommentInput> {
  final _textController = TextEditingController();
  var _hasFocus = false;
  var _currentPosition = Duration.zero;

  var _sendPosition = true;

  @override
  void initState() {
    super.initState();

    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_onFocusNodeChanged);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusNodeChanged);
    _textController.dispose();

    super.dispose();
  }

  void _onFocusNodeChanged() {
    if (widget.focusNode!.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = widget.focusNode!.hasFocus;
        if (_hasFocus) {
          _currentPosition = context.read<VersionCubit>().audioPlayer.currentPosition;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EditCommentCubit, EditCommentState, bool>(
      selector: (state) {
        return state.comment != null;
      },
      builder: (context, isCommentEdit) {
        return Container(
          constraints: BoxConstraints.loose(const Size(800, 110)),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentPositionSwitch(
                enabled: !isCommentEdit,
                position: _currentPosition,
                onChanged: (isChecked) {
                  _sendPosition = isChecked;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: !isCommentEdit,
                      controller: _textController,
                      focusNode: widget.focusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: isCommentEdit
                            ? 'Wciśnij Enter, aby zatwierdzić edycję'
                            : !(widget.focusNode?.hasFocus ?? false)
                                ? 'Wciśnij Enter, aby rozpocząć dodawanie komentarza'
                                : 'Wpisz treść komentarza. Wciśnij ESC, aby anulować',
                      ),
                      onSubmitted: (value) {
                        final text = value.trim();

                        if (text.isNotEmpty) {
                          _submit(text);
                        }
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _textController.text.trim().isNotEmpty
                        ? () {
                            _submit(_textController.text);
                          }
                        : null,
                    icon: const Icon(Icons.send),
                    tooltip: 'Wyślij [Enter]',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(String text) {
    context
        .read<VersionCubit>()
        .addComment(text, startPosition: _sendPosition ? _currentPosition : null, endPosition: null);

    _textController.clear();
  }
}
