import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final _player = AudioPlayer();

  String? _sourceUrl;

  void initialize(String sourceUrl) {
    _sourceUrl = sourceUrl;

    // _player.eventStream.listen((event) {
    //   print(event);
    // });
  }

  Future<void> play() async {
    if (_sourceUrl == null) {
      throw Exception('No source url');
    }

    await _player.play(UrlSource(_sourceUrl!));
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Stream<Duration> get positionChanges => _player.onPositionChanged;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
