import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:band_space/song/screens/widgets/comment_position_switch.dart';

class VersionCommentInput extends StatefulWidget {
  const VersionCommentInput({
    super.key,
    required this.onSubmitted,
    required this.getCurrentPosition,
    this.focusNode,
  });

  final Duration Function() getCurrentPosition;
  final void Function(String value, Duration? startPosition, Duration? endPosition) onSubmitted;
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
          _currentPosition = widget.getCurrentPosition();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            position: _currentPosition,
            onChanged: (isChecked) {
              _sendPosition = isChecked;
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: widget.focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: kIsWeb && !(widget.focusNode?.hasFocus ?? false)
                        ? 'Wciśnij Enter, aby rozpocząć dodawanie komentarza'
                        : 'Wpisz treść komentarza${kIsWeb ? '. Wciśnij ESC, aby anulować' : ''}',
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
  }

  void _submit(String text) {
    final startPosition = _sendPosition ? _currentPosition : null;

    widget.onSubmitted(text, startPosition, null);
    _textController.clear();
  }
}
