import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final _player = AudioPlayer();

  AudioPlayerService() {
    _player.playerStateStream.listen(_handlePlayerStateChange);
  }

  bool get isPlaying => _player.playing;
  Stream<bool> get isPlayingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;

  Future<Duration?> setUrl(String url) async {
    return _player.setUrl(url, preload: false);
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  void _handlePlayerStateChange(PlayerState state) async {
    print(state);

    if (state.processingState == ProcessingState.completed) {
      await pause();
      await seek(Duration.zero);
    }
  }
}
