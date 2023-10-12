import 'package:flutter/material.dart';

import 'package:band_space/utils/duration_extensions.dart';

class SongTimeline extends StatelessWidget {
  const SongTimeline({
    super.key,
    required this.currentPosition,
    required this.duration,
    required this.onPositionChanged,
  });

  final Duration currentPosition;
  final Duration duration;
  final Function(Duration position) onPositionChanged;

  static const widgetHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _Timeline(
          width: constraints.maxWidth,
          height: widgetHeight,
          currentPosition: currentPosition,
          duration: duration,
          onPositionChanged: onPositionChanged,
        );
      },
    );
  }
}

class _Timeline extends StatefulWidget {
  const _Timeline({
    // ignore: unused_element
    super.key,
    required this.width,
    required this.height,
    required this.currentPosition,
    required this.duration,
    required this.onPositionChanged,
  });

  final double width;
  final double height;
  final Duration currentPosition;
  final Duration duration;
  final Function(Duration position) onPositionChanged;

  @override
  State<_Timeline> createState() => __TimelineState();
}

class __TimelineState extends State<_Timeline> {
  late var _currentPosition = widget.currentPosition;
  late var _handlePosition = _songPositionToHandlePosition();
  var _isHandleDragging = false;
  var _isHandleHovered = false;

  Duration _handlePositionToSongCurrentPosition() {
    final logicalPosition = _handlePosition / widget.width;
    // print('logicalPosition: $logicalPosition');

    final songPositionInMs = (widget.duration.inMilliseconds * logicalPosition).truncate();

    return Duration(milliseconds: songPositionInMs);
  }

  double _songPositionToHandlePosition() {
    final logicalPosition = _currentPosition.inMilliseconds / widget.duration.inMilliseconds;
    // print('current: ${_currentPosition.inMilliseconds}');
    // print('total: ${widget.duration.inMilliseconds}');

    return widget.width * logicalPosition;
  }

  @override
  void didUpdateWidget(covariant _Timeline oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.width != oldWidget.width) {
      // where handle was on timeline from 0 to 1
      final logicalPosition = _handlePosition / oldWidget.width;
      _handlePosition = widget.width * logicalPosition;
    }

    if (widget.currentPosition != oldWidget.currentPosition) {
      if (!_isHandleDragging) {
        _currentPosition = widget.currentPosition;
        _handlePosition = _songPositionToHandlePosition();

        // print(_handlePosition);
      }
    }

    // print('didUpdateWidget');
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isHandleHovered ? SystemMouseCursors.click : MouseCursor.defer,
      onHover: (event) {
        final touchXPosition = event.localPosition.dx;
        final touchYPosition = event.localPosition.dy;

        const dragTouchSize = Size.square(TimelinePainter.handleDraggingRadius);

        final isInX = (touchXPosition - _handlePosition).abs() <= dragTouchSize.width;
        final isInY = (touchYPosition - widget.height / 2).abs() <= dragTouchSize.height;

        if (isInX && isInY) {
          if (!_isHandleHovered) {
            setState(() {
              _isHandleHovered = true;
            });
          }
        } else if (_isHandleHovered) {
          setState(() {
            _isHandleHovered = false;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            _isHandleDragging = true;
            _handlePosition = details.localPosition.dx;
            _currentPosition = _handlePositionToSongCurrentPosition();
          });
        },
        onTapUp: (details) {
          setState(() {
            _isHandleDragging = false;
          });
          widget.onPositionChanged(_currentPosition);
        },
        onPanStart: (details) {
          setState(() {
            _isHandleDragging = true;
          });
        },
        onPanUpdate: (details) {
          if (_isHandleDragging) {
            setState(() {
              _handlePosition = (_handlePosition + details.delta.dx).clamp(0, widget.width);

              if (details.localPosition.dx < 0 && _handlePosition > 0) {
                _handlePosition = 0;
              } else if (details.localPosition.dx > widget.width && _handlePosition < widget.width) {
                _handlePosition = widget.width;
              }

              _currentPosition = _handlePositionToSongCurrentPosition();
            });
          }
        },
        onPanEnd: (details) {
          if (_isHandleDragging) {
            setState(() {
              _isHandleDragging = false;
            });

            widget.onPositionChanged(_currentPosition);
          }
        },
        child: CustomPaint(
          painter: TimelinePainter(
            handlePosition: _handlePosition,
            isHandleDragging: _isHandleDragging,
          ),
          child: Container(
            // padding: const EdgeInsets.symmetric(horizontal: 10),
            // color: Colors.grey.withOpacity(0.1),
            width: widget.width,
            height: widget.height,
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.labelSmall!,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_currentPosition.format()),
                    Text(widget.duration.format()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double handlePosition;
  final bool isHandleDragging;
  static const handleDefaultRadius = 5.5;
  static const handleDraggingRadius = 6.7;

  TimelinePainter({
    super.repaint,
    required this.handlePosition,
    required this.isHandleDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // print(size);

    final backgroundLinePaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final startingLinePoint = Offset(0, size.height / 2);
    final endingBackgroundLinePoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startingLinePoint, endingBackgroundLinePoint, backgroundLinePaint);

    final foregroundLinePaint = backgroundLinePaint..color = Colors.white;
    final endingForegroundLinePoint = Offset(handlePosition.clamp(0, size.width), size.height / 2);

    canvas.drawLine(startingLinePoint, endingForegroundLinePoint, foregroundLinePaint);

    final handlePaint = Paint()..color = Colors.white;

    final handleOffset = Offset(handlePosition.clamp(0.0, size.width), size.height / 2);
    final handleRadius = isHandleDragging ? handleDraggingRadius : handleDefaultRadius;
    canvas.drawCircle(handleOffset, handleRadius, handlePaint);
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    // return true;
    return handlePosition != oldDelegate.handlePosition || isHandleDragging != oldDelegate.isHandleDragging;
  }
}
