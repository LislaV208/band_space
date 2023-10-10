import 'dart:convert';

class MarkerDTO {
  final String name;
  final int startPosition;
  final int? endPosition;

  const MarkerDTO({
    required this.name,
    required this.startPosition,
    required this.endPosition,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_position': startPosition,
      'end_position': endPosition,
    };
  }

  factory MarkerDTO.fromMap(Map<String, dynamic> map) {
    return MarkerDTO(
      name: map['name'] ?? '',
      startPosition: map['start_position']?.toInt() ?? 0,
      endPosition: map['end_position']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MarkerDTO.fromJson(String source) => MarkerDTO.fromMap(json.decode(source));
}
