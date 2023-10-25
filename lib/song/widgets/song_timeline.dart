import 'package:flutter/material.dart';

import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/song/screens/timeline_state.dart';
import 'package:band_space/song/screens/widgets/timeline_comment_markers.dart';
import 'package:band_space/utils/duration_extensions.dart';

class SongTimeline extends StatefulWidget {
  const SongTimeline({
    super.key,
    required this.positionStream,
    required this.bufferStream,
    required this.duration,
    required this.onPositionChanged,
    required this.commentsStream,
    required this.selectedComment,
    required this.onSelectedCommentChange,
  });

  final Stream<Duration> positionStream;
  final Stream<Duration> bufferStream;
  final Duration duration;
  final Function(Duration position) onPositionChanged;
  final Stream<List<VersionComment>> commentsStream;
  final VersionComment? selectedComment;
  final void Function(VersionComment? comment) onSelectedCommentChange;

  static const widgetHeight = 60.0;

  @override
  State<SongTimeline> createState() => _SongTimelineState();
}

class _SongTimelineState extends State<SongTimeline> {
  TimelineState? _state;

  @override
  Widget build(BuildContext context) {
    const paddingValue = 20.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // potrzebne aby nie utracić stanu podczas resize
        final maxWidth = constraints.maxWidth - paddingValue * 2;

        if (_state == null) {
          _state = TimelineState(
            width: maxWidth,
            height: SongTimeline.widgetHeight,
            songPositionStream: widget.positionStream,
            songBufferStream: widget.bufferStream,
            songDuration: widget.duration,
            onPositionChanged: widget.onPositionChanged,
          );
        } else {
          _state!.width = maxWidth;
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingValue),
              child: _Timeline(state: _state!),
            ),
            TimelineCommentMarkers(
              commentsStream: widget.commentsStream,
              selectedComment: widget.selectedComment,
              songDuration: widget.duration,
              maxWidth: constraints.maxWidth - (paddingValue * 2),
              onSelectedCommentChange: widget.onSelectedCommentChange,
            ),
          ],
        );
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
                    padding: const EdgeInsets.only(bottom: 0.0),
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
    // print(size);

    final backgroundLinePaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final startingLinePoint = Offset(0, size.height / 2);
    final endingBackgroundLinePoint = Offset(size.width, size.height / 2);

    // background line
    canvas.drawLine(startingLinePoint, endingBackgroundLinePoint, backgroundLinePaint);

    final bufferLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // buffer line
    canvas.drawLine(
      startingLinePoint,
      Offset(state.bufferPositionInPixels.clamp(0, size.width), size.height / 2),
      bufferLinePaint,
    );

    final foregroundLinePaint = backgroundLinePaint..color = Colors.white;
    final endingForegroundLinePoint = Offset(state.currentPositionInPixels.clamp(0, size.width), size.height / 2);

    // position line
    canvas.drawLine(startingLinePoint, endingForegroundLinePoint, foregroundLinePaint);

    final handlePaint = Paint()..color = Colors.white;

    final handleOffset = Offset(state.currentPositionInPixels.clamp(0.0, size.width), size.height / 2);
    final handleRadius = state.isHandleDragging ? handleDraggingRadius : handleDefaultRadius;

    // handle circle
    canvas.drawCircle(handleOffset, handleRadius, handlePaint);
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return state != oldDelegate.state;
  }
}
