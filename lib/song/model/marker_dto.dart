class MarkerDTO {
  final String name;
  final int startPosition;
  final int? endPosition;

  const MarkerDTO({
    required this.name,
    required this.startPosition,
    required this.endPosition,
  });
}
