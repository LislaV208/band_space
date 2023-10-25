import 'package:flutter/material.dart';

class HoverWidget extends StatefulWidget {
  const HoverWidget({
    super.key,
    required this.builder,
    this.showCursor = true,
  });

  final Widget Function(BuildContext context, bool isHovered) builder;
  final bool showCursor;

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.showCursor && _isHovered ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (event) => setState(() {
        _isHovered = true;
      }),
      onExit: (event) => setState(() {
        _isHovered = false;
      }),
      child: widget.builder(context, _isHovered),
    );
  }
}
