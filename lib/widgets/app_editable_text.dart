import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppEditableText extends StatefulWidget {
  const AppEditableText(
    this.data, {
    super.key,
    required this.onEdited,
    this.editable = true,
    this.autofocus = false,
  });

  final String data;
  final void Function(String value) onEdited;
  final bool editable;
  final bool autofocus;

  @override
  State<AppEditableText> createState() => _AppEditableTextState();
}

class _AppEditableTextState extends State<AppEditableText> {
  late TextEditingController _textController;
  late FocusNode _textFieldFocusNode;

  var _isEditing = false;
  var _textFieldFocused = false;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.data);

    _textFieldFocusNode = FocusNode();
    _textFieldFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AppEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);

    _textController.text = widget.data;

    if (widget.autofocus) {
      _enableEditing();
    }
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_onFocusChanged);

    _textController.dispose();
    _textFieldFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            controller: _textController,
            enabled: _isEditing,
            focusNode: _textFieldFocusNode,
            style: DefaultTextStyle.of(context).style,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: _isEditing ? null : InputBorder.none,
              contentPadding: const EdgeInsets.all(8),
              filled: _isEditing,
              fillColor: Theme.of(context).primaryColorDark.withOpacity(0.3),
              counter: const SizedBox.shrink(),
            ),
            minLines: 1,
            maxLines: _isEditing ? 1 : 2,
            maxLength: 30,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
          ),
        ),
        if (widget.editable && !_isEditing)
          Positioned.fill(
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: GestureDetector(
                onTapDown: (_) => _enableEditing(),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
      ],
    );
  }

  void _onFocusChanged() {
    if (_textFieldFocusNode.hasFocus) {
      _textFieldFocused = true;
      print('FOCUSED');
    } else {
      if (_textFieldFocused) {
        print('NOT FOCUSED');
        if (_textController.text.isNotEmpty) {
          widget.onEdited(_textController.text);
        } else {
          _textController.text = widget.data;
        }

        _textFieldFocusNode.unfocus();
        setState(() {
          _isEditing = false;
        });
      }
      _textFieldFocused = false;
    }
  }

  void _enableEditing() {
    setState(() {
      _isEditing = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _textFieldFocusNode.requestFocus();
    });
  }
}
