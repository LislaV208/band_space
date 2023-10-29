import 'package:flutter/material.dart';

class HoverWidget extends StatefulWidget {
  const HoverWidget({
    super.key,
    required this.builder,
    this.showCursor = true,
    this.onHoverEnter,
    this.onHoverExit,
  });

  final Widget Function(BuildContext context, bool isHovered) builder;
  final bool showCursor;
  final void Function()? onHoverEnter;
  final void Function()? onHoverExit;

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.showCursor && _isHovered ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (event) {
        widget.onHoverEnter?.call();
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        widget.onHoverExit?.call();
        setState(() {
          _isHovered = false;
        });
      },
      child: widget.builder(context, _isHovered),
    );
  }
}
