import 'package:flutter/material.dart';

import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/screens/timeline_state.dart';
import 'package:band_space/utils/duration_extensions.dart';

class SongTimeline extends StatefulWidget {
  const SongTimeline({
    super.key,
    required this.positionStream,
    required this.duration,
    required this.onPositionChanged,
    required this.markersStream,
    required this.onMarkerTap,
  });

  final Stream<Duration> positionStream;
  final Duration duration;
  final Function(Duration position) onPositionChanged;
  final Stream<List<Marker>> markersStream;
  final void Function(Marker marker) onMarkerTap;

  static const widgetHeight = 80.0;

  @override
  State<SongTimeline> createState() => _SongTimelineState();
}

class _SongTimelineState extends State<SongTimeline> {
  TimelineState? _state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // potrzebne aby nie utracić stanu podczas resize
        if (_state == null) {
          _state = TimelineState(
            width: constraints.maxWidth,
            height: SongTimeline.widgetHeight,
            songPositionStream: widget.positionStream,
            songDuration: widget.duration,
            markersStream: widget.markersStream,
            onPositionChanged: widget.onPositionChanged,
            onMarkerTap: widget.onMarkerTap,
          );
        } else {
          _state!.width = constraints.maxWidth;
        }

        return _Timeline(state: _state!);
      },
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    // ignore: unused_element
    super.key,
    required this.state,
  });
  final TimelineState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        return MouseRegion(
          cursor: state.showHoverCursor ? SystemMouseCursors.click : MouseCursor.defer,
          onHover: (event) => state.onHover(event.localPosition),
          child: GestureDetector(
            onTapDown: (details) => state.onTapDown(details.localPosition),
            onTapUp: (details) => state.onTapUp(details.localPosition),
            onPanStart: (details) => state.onDragStart(details),
            onPanUpdate: (details) => state.onDragUpdate(details),
            onPanEnd: (details) => state.onDragEnd(details),
            child: CustomPaint(
              painter: TimelinePainter(state: state),
              child: SizedBox(
                width: state.width,
                height: state.height,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.labelSmall!,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(state.currentPositionInDuration.format()),
                        Text(state.songDuration.format()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TimelinePainter extends CustomPainter {
  final TimelineState state;

  static const handleDefaultRadius = 5.5;
  static const handleDraggingRadius = 6.7;

  TimelinePainter({
    required this.state,
  }) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    for (final marker in state.markers) {
      _paintMarker(marker, canvas, size);
    }

    final backgroundLinePaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final startingLinePoint = Offset(0, size.height / 2);
    final endingBackgroundLinePoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startingLinePoint, endingBackgroundLinePoint, backgroundLinePaint);

    final foregroundLinePaint = backgroundLinePaint..color = Colors.white;
    final endingForegroundLinePoint = Offset(state.currentPositionInPixels.clamp(0, size.width), size.height / 2);

    canvas.drawLine(startingLinePoint, endingForegroundLinePoint, foregroundLinePaint);

    final handlePaint = Paint()..color = Colors.white;

    final handleOffset = Offset(state.currentPositionInPixels.clamp(0.0, size.width), size.height / 2);
    final handleRadius = state.isHandleDragging ? handleDraggingRadius : handleDefaultRadius;
    canvas.drawCircle(handleOffset, handleRadius, handlePaint);
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return state != oldDelegate.state;
  }

  static const markerSize = 20.0;
  static const markerJointSize = 2.0;

  void _paintMarker(TimelineMarker marker, Canvas canvas, Size size) {
    final isTimestampMarker = marker.endPosition == null;

    final markerPaint = Paint()
      ..color = isTimestampMarker ? Colors.blue : Colors.red
      ..strokeWidth = markerSize;

    final markerJointPaint = Paint()
      ..color = isTimestampMarker ? Colors.blue : Colors.red
      ..strokeWidth = markerJointSize;

    const fontSize = 13.0;

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: fontSize,
    );
    final textSpan = TextSpan(
      text: marker.name,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      ellipsis: '..',
      maxLines: 1,
    );

    const padding = 4.0;

    if (isTimestampMarker) {
      textPainter.layout(maxWidth: 80);
    }

    final startX = marker.startPosition * size.width;
    final endX = (isTimestampMarker ? startX + textPainter.width : marker.endPosition! * size.width) + padding;

    if (!isTimestampMarker) {
      textPainter.layout(maxWidth: endX - startX);
    }

    final rect = Rect.fromLTRB(
      startX,
      (size.height / 2) - (handleDefaultRadius * 2) - textPainter.height - padding,
      endX + (isTimestampMarker ? padding : 0.0),
      (size.height / 2) - (handleDefaultRadius * 2),
    );

    canvas.drawRect(rect, markerPaint);

    state.updateMarkerRect(marker, rect);

    canvas.drawLine(
      Offset(
        startX + markerJointSize / 2,
        (size.height / 2) - (handleDefaultRadius * 2),
      ),
      Offset(
        startX + markerJointSize / 2,
        size.height / 2,
      ),
      markerJointPaint,
    );

    if (!isTimestampMarker) {
      canvas.drawLine(
        Offset(
          endX - markerJointSize / 2,
          (size.height / 2) - (handleDefaultRadius * 2),
        ),
        Offset(
          endX - markerJointSize / 2,
          size.height / 2,
        ),
        markerJointPaint,
      );
    }

    final position =
        Offset(startX + padding, size.height / 2 - handleDefaultRadius * 2 - textPainter.height - padding / 2);
    textPainter.paint(canvas, position);
  }
}
