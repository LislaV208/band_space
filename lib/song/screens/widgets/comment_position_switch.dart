import 'package:flutter/material.dart';

import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/hover_widget.dart';

class CommentPositionSwitch extends StatefulWidget {
  const CommentPositionSwitch({
    super.key,
    required this.position,
    required this.onChanged,
  });

  final Duration position;
  final void Function(bool isChecked) onChanged;

  @override
  State<CommentPositionSwitch> createState() => _CommentPositionSwitchState();
}

class _CommentPositionSwitchState extends State<CommentPositionSwitch> {
  var _isChecked = true;

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.lightBlue[800]!;
    const disabledColor = Colors.grey;

    return HoverWidget(builder: (context, isHovered) {
      return GestureDetector(
        onTap: () => setState(() {
          _isChecked = !_isChecked;

          widget.onChanged(_isChecked);
        }),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(isHovered ? 0.6 : 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: _isChecked ? activeColor : disabledColor,
                ),
              ),
              Text(
                widget.position.format(),
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: _isChecked ? activeColor : disabledColor,
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  side: _isChecked ? BorderSide.none : const BorderSide(color: disabledColor),
                  // side: BorderSide.none,
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });

                    widget.onChanged(_isChecked);
                  },
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    // if (states.contains(MaterialState.disabled)) {
                    //   return Colors.black;
                    // }
                    return _isChecked
                        ? isHovered
                            ? Colors.lightBlue[500]!
                            : activeColor
                        : Colors.transparent;
                  }),
                  overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    return Colors.transparent;
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
