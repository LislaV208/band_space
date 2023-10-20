import 'dart:convert';

class MarkerDTO {
  final String name;
  final Duration startPosition;
  final Duration? endPosition;

  const MarkerDTO({
    required this.name,
    required this.startPosition,
    required this.endPosition,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_position': startPosition.inMilliseconds,
      'end_position': endPosition?.inMilliseconds,
    };
  }

  String toJson() => json.encode(toMap());
}
