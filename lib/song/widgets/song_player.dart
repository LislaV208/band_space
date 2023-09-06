import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SongPlayer extends StatefulWidget {
  const SongPlayer({
    super.key,
    required this.fileUrl,
    required this.duration,
  });

  final String fileUrl;
  final int duration;

  @override
  State createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  int _currentPosition = 0;
  late int _duration = widget.duration;

  final _player = AudioPlayer();

  var _isPlaying = false;

  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () => init());
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player.dispose();

    super.dispose();
  }

  void init() async {
    if (_duration == 0) {
      await _player.setSourceUrl(widget.fileUrl);
      final duration = await _player.getDuration();
      if (duration != null) {
        setState(() {
          _duration = duration.inSeconds;
        });
      }
    }

    _positionSub = _player.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position.inSeconds;

        if (_isPlaying && _currentPosition == _duration) {
          _isPlaying = false;

          _player.pause();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Slider(
              value: _currentPosition.toDouble(),
              min: 0,
              max: _duration.toDouble(),
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                  ),
                  Text(
                    _formatDuration(_duration),
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.fast_rewind,
              ),
              iconSize: 40,
            ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              color: Theme.of(context).primaryColor,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              iconSize: 40,
              onPressed: () async {
                if (_isPlaying) {
                  _player.pause();
                } else {
                  if (_currentPosition == _duration) {
                    await _player.seek(Duration.zero);
                  }

                  _player.play(UrlSource(widget.fileUrl));
                }

                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.fast_forward,
              ),
              iconSize: 40,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = (durationInSeconds / 60).floor();
    final seconds = (durationInSeconds % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
