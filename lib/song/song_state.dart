enum SongState {
  draft(value: _draftValue),
  demo(value: _demoValue),
  finalVersion(value: _finalValue);

  static const _draftValue = 'draft';
  static const _demoValue = 'demo';
  static const _finalValue = 'final_version';

  const SongState({
    required this.value,
  });

  final String value;

  factory SongState.fromString(String value) {
    switch (value) {
      case _draftValue:
        return SongState.draft;
      case _demoValue:
        return SongState.demo;
      case _finalValue:
        return SongState.finalVersion;

      default:
        return SongState.draft; // TODO: poprawić kiedyś
    }
  }
}
