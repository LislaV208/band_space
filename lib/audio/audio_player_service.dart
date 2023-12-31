import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'package:band_space/audio/loop_sections_manager.dart';

class AudioPlayerService {
  final _player = AudioPlayer();
  final _loopSectionsManager = LoopSectionsManager();

  StreamSubscription<Duration>? _positionStreamSubscription;
  final _loadingController = BehaviorSubject<bool>();

  AudioPlayerService() {
    _player.playerStateStream.listen(_handlePlayerStateChange);
  }

  bool get isPlaying => _player.playing;

  Duration get currentPosition => _player.position;

  Stream<bool> get isPlayingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get bufferStream => _player.bufferedPositionStream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<bool> get loopModeStream => _player.loopModeStream.map((event) => event != LoopMode.off);
  Stream<List<LoopSection>> get loopSectionsStream => _loopSectionsManager.loopSectionsStream;

  var _isLoading = false;

  Future<void> toggleLoopMode() async {
    await _player.setLoopMode(
      _player.loopMode == LoopMode.off ? LoopMode.one : LoopMode.off,
    );
  }

  void addLoopSection(LoopSection loopSection) {
    _loopSectionsManager.addSection(loopSection);

    // listen to position stream only when first loop section is added
    if (_loopSectionsManager.sections.length == 1) {
      _positionStreamSubscription = positionStream.listen((position) {
        for (final section in _loopSectionsManager.joinedSections) {
          if (position >= section.end) {
            seek(section.start);

            // no need to check other sections
            break;
          }
        }
      });
    }
  }

  void updateLoopSection(LoopSection current, LoopSection updated) {
    _loopSectionsManager.updateLoopSection(current, updated);
  }

  Future<void> removeLoopSection(LoopSection loopSection) async {
    _loopSectionsManager.removeSection(loopSection);

    if (_loopSectionsManager.sections.isEmpty) {
      await _positionStreamSubscription?.cancel();
    }
  }

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

  Future<void> forward() async {
    final currentPosition = _player.position;
    await seek(currentPosition + const Duration(seconds: 5));
  }

  Future<void> rewind() async {
    final currentPosition = _player.position;
    await seek(currentPosition - const Duration(seconds: 5));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _loopSectionsManager.dispose();
    await _positionStreamSubscription?.cancel();
    await _loadingController.close();

    await _player.dispose();
  }

  void _handlePlayerStateChange(PlayerState state) async {
    print(state);

    if (state.processingState == ProcessingState.loading) {
      _isLoading = true;
      _loadingController.add(true);
    } else {
      if (_isLoading) {
        _isLoading = false;
        _loadingController.add(false);
      }

      if (state.processingState == ProcessingState.completed) {
        await pause();
        await seek(Duration.zero);
      }
    }
  }
}
