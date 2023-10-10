import 'package:band_space/song/model/marker.dart';

class MarkerCollisionValidator {
  final List<Marker> currentMarkers;
  final int? start;
  final int? end;

  const MarkerCollisionValidator({
    required this.currentMarkers,
    required this.start,
    required this.end,
  });

  // returns list of colliding markers
  // if empty, then marker is valid
  List<Marker> validate() {
    if (start != null && end == null) {
      return _validateTimestampMarkers();
    } else if (start != null && end != null) {
      if (start == end) {
        return _validateTimestampMarkers();
      }

      return _validateSectionMarkers();
    }

    return [];
  }

  List<Marker> _validateTimestampMarkers() {
    final timestampMarkers = currentMarkers.where((element) => element.end_position == null).toList();
    final collisionMarkers = timestampMarkers.where((element) => element.start_position == start).toList();

    return collisionMarkers;
  }

  List<Marker> _validateSectionMarkers() {
    final sectionMarkers = currentMarkers.where((marker) => marker.end_position != null).toList();
    final collisionMarkers = sectionMarkers.where((marker) => _checkSelectionMarker(marker)).toList();

    return collisionMarkers;
  }

  bool _checkSelectionMarker(Marker marker) {
    //1. starts before, but overlaps the marker
    if (start! < marker.start_position && end! > marker.start_position) {
      return true;
    }

    //2. starts inside marker
    if (start! >= marker.start_position && start! < marker.end_position!) {
      return true;
    }

    return false;
  }
}
