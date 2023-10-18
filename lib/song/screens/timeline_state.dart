import 'dart:async';

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/widgets/song_timeline.dart';

class TimelineMarker extends Equatable {
  const TimelineMarker({
    required this.name,
    required this.startPosition,
    required this.endPosition,
    this.rect = Rect.zero,
  });

  final String name;
  final double startPosition;
  final double? endPosition;
  final Rect rect;

  factory TimelineMarker.fromMarker(Marker marker, Duration songDuration) {
    return TimelineMarker(
      name: marker.name,
      startPosition: Duration(seconds: marker.start_position).inMilliseconds / songDuration.inMilliseconds,
      endPosition: marker.end_position != null
          ? Duration(seconds: marker.end_position!).inMilliseconds / songDuration.inMilliseconds
          : null,
    );
  }

  TimelineMarker copyWithRect(Rect newRect) =>
      TimelineMarker(name: name, startPosition: startPosition, endPosition: endPosition, rect: newRect);

  @override
  List<Object?> get props => [name, startPosition, endPosition, rect];
}

// ignore: must_be_immutable
class TimelineState extends Equatable with ChangeNotifier {
  double width;
  final double height;
  final Stream<Duration> songPositionStream;
  final Stream<Duration> songBufferStream;
  final Duration songDuration;
  final Stream<List<Marker>> markersStream;
  final void Function(Duration position) onPositionChanged;
  final void Function(Marker marker) onMarkerTap;

  StreamSubscription<double>? _positionStreamSubscription;
  StreamSubscription<double>? _bufferStreamSubscription;
  StreamSubscription<List<Marker>>? _markersStreamSubscription;

  TimelineState({
    required this.width,
    required this.height,
    required this.songPositionStream,
    required this.songBufferStream,
    required this.songDuration,
    required this.markersStream,
    required this.onPositionChanged,
    required this.onMarkerTap,
  }) {
    print('TimelineState()');
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

    _markersStreamSubscription = markersStream.listen((markers) {
      _originalMarkers = markers;
      this.markers = markers.map((marker) => TimelineMarker.fromMarker(marker, songDuration)).toList();

      notifyListeners();
    });
  }

  @override
  List<Object> get props {
    return [currentPosition, isHandleDragging, showHoverCursor, markers];
  }

  @override
  void dispose() {
    print('timeline state dispose');
    _positionStreamSubscription?.cancel();
    _bufferStreamSubscription?.cancel();
    _markersStreamSubscription?.cancel();

    super.dispose();
  }

  // logical position - from 0.0 to 1.0
  // where 0.0 is start and 1.0 is end
  var currentPosition = 0.0;
  var bufferPosition = 0.0;
  var showHoverCursor = false;
  var isHandleDragging = false;
  var _originalMarkers = <Marker>[];
  var markers = <TimelineMarker>[];

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

    for (final marker in markers) {
      _detectMarkerHover(marker, position);

      // jezeli hover wykryty, to nie szukamy dalej
      if (showHoverCursor) break;
    }
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
    } else {
      for (var i = 0; i < markers.length; ++i) {
        final marker = markers[i];

        if (marker.rect.contains(tapPosition)) {
          onMarkerTap(_originalMarkers[i]);

          break;
        }
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

  void updateMarkerRect(TimelineMarker marker, Rect rect) {
    final index = markers.indexOf(marker);

    if (index >= 0) {
      markers[index] = marker.copyWithRect(rect);
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

  void _detectMarkerHover(TimelineMarker marker, Offset hoverPosition) {
    if (marker.rect.contains(hoverPosition)) {
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
