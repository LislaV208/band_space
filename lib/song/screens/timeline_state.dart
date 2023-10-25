import 'dart:async';

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';

import 'package:band_space/song/widgets/song_timeline.dart';

// ignore: must_be_immutable
class TimelineState extends Equatable with ChangeNotifier {
  double width;
  final double height;
  final Stream<Duration> songPositionStream;
  final Stream<Duration> songBufferStream;
  final Duration songDuration;
  final void Function(Duration position) onPositionChanged;

  StreamSubscription<double>? _positionStreamSubscription;
  StreamSubscription<double>? _bufferStreamSubscription;

  TimelineState({
    required this.width,
    required this.height,
    required this.songPositionStream,
    required this.songBufferStream,
    required this.songDuration,
    required this.onPositionChanged,
  }) {
    _positionStreamSubscription =
        songPositionStream.map((position) => position.inMilliseconds / songDuration.inMilliseconds).listen((position) {
      if (!isHandleDragging) {
        currentPosition = position;

        notifyListeners();
      }
    });

    _bufferStreamSubscription =
        songBufferStream.map((position) => position.inMilliseconds / songDuration.inMilliseconds).listen((position) {
      bufferPosition = position;
    });
  }

  @override
  List<Object> get props {
    return [currentPosition, isHandleDragging, showHoverCursor];
  }

  @override
  void dispose() {
    print('timeline state dispose');
    _positionStreamSubscription?.cancel();
    _bufferStreamSubscription?.cancel();

    super.dispose();
  }

  // logical position - from 0.0 to 1.0
  // where 0.0 is start and 1.0 is end
  var currentPosition = 0.0;
  var bufferPosition = 0.0;
  var showHoverCursor = false;
  var isHandleDragging = false;

  double get currentPositionInPixels => currentPosition * width;
  double get bufferPositionInPixels => bufferPosition * width;
  Duration get currentPositionInDuration => Duration(
        milliseconds: (currentPosition * songDuration.inMilliseconds).round(),
      );

  double _pixelToLogicalPosition(double x) => x / width;
  Duration _logicalToDurationPosition(double x) => Duration(milliseconds: (songDuration.inMilliseconds * x).round());

  void onHover(Offset position) {
    _detectHandleHover(position);

    // jezeli hover wykryty, to nie szukamy dalej
    if (showHoverCursor) return;
  }

  void onTapDown(Offset tapPosition) {
    if (tapPosition.dy > height / 2 - TimelinePainter.handleDraggingRadius / 2 &&
        tapPosition.dy < height / 2 + TimelinePainter.handleDraggingRadius) {
      final newPosition = _pixelToLogicalPosition(tapPosition.dx);
      if (newPosition != currentPosition) {
        currentPosition = newPosition;

        notifyListeners();
      }

      if (isHandleDragging == false) {
        isHandleDragging = true;

        notifyListeners();
      }
    }
  }

  void onTapUp(Offset position) {
    if (isHandleDragging == true) {
      isHandleDragging = false;

      onPositionChanged(_logicalToDurationPosition(currentPosition));

      notifyListeners();
    }
  }

  void onDragStart(DragStartDetails details) {
    if (isHandleDragging == false) {
      isHandleDragging = true;

      notifyListeners();
    }
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (isHandleDragging) {
      var newPixelPosition = (currentPositionInPixels + details.delta.dx).clamp(0, width);

      if (details.localPosition.dx < 0 && newPixelPosition > 0) {
        newPixelPosition = 0;
      } else if (details.localPosition.dx > width && newPixelPosition < width) {
        newPixelPosition = width;
      }

      final newPosition = _pixelToLogicalPosition(newPixelPosition.toDouble());
      if (newPosition != currentPosition) {
        currentPosition = newPosition;

        notifyListeners();
      }
    }
  }

  void onDragEnd(DragEndDetails details) {
    if (isHandleDragging == true) {
      isHandleDragging = false;

      onPositionChanged(_logicalToDurationPosition(currentPosition));

      notifyListeners();
    }
  }

  void _detectHandleHover(Offset hoverPosition) {
    final isInX = (hoverPosition.dx - currentPositionInPixels).abs() <= TimelinePainter.handleDraggingRadius;
    final isInY = (hoverPosition.dy - height / 2).abs() <= TimelinePainter.handleDraggingRadius;

    if (isInX && isInY) {
      if (!showHoverCursor) {
        showHoverCursor = true;

        notifyListeners();
      }
    } else if (showHoverCursor) {
      showHoverCursor = false;

      notifyListeners();
    }
  }
}
