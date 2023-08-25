import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SongPlayer extends StatefulWidget {
  const SongPlayer({super.key, required this.fileUrl});

  final String fileUrl;

  @override
  State createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  int _currentPosition = 0;
  int _totalDuration = 0;

  final _player = AudioPlayer();

  var _isPlaying = false;

  late StreamSubscription<Duration> _positionSub;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () => init());
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _player.dispose();

    super.dispose();
  }

  void init() async {
    await _player.setSourceUrl(widget.fileUrl);

    _positionSub = _player.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position.inSeconds;

        if (_isPlaying && _currentPosition == _totalDuration) {
          _isPlaying = false;

          _player.pause();
        }
      });
    });

    final duration = await _player.getDuration();
    setState(() {
      _totalDuration = duration?.inSeconds ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Slider(
            value: _currentPosition.toDouble(),
            min: 0,
            max: _totalDuration.toDouble(),
            onChanged: (value) {
              _player.seek(Duration(seconds: value.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () async {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    if (_currentPosition == _totalDuration) {
                      await _player.seek(Duration.zero);
                    }

                    _player.play(UrlSource(widget.fileUrl));
                  }

                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
              Text(
                _formatDuration(_totalDuration),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = (durationInSeconds / 60).floor();
    final seconds = (durationInSeconds % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
