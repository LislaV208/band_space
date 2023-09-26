import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/version_file_model.dart';
import 'package:flutter/material.dart';

class SongPlayer extends StatefulWidget {
  const SongPlayer({
    super.key,
    required this.file,
  });

  final VersionFileModel file;

  @override
  State createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  final _audioPlayer = sl<AudioPlayerService>();

  @override
  void initState() {
    super.initState();

    _audioPlayer.setUrl(widget.file.download_url);
  }

  @override
  void dispose() {
    _audioPlayer.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final currentPosition = (snapshot.data ?? Duration.zero).inSeconds;

              return Column(
                children: [
                  Slider(
                    value: currentPosition.toDouble(),
                    min: 0,
                    max: widget.file.duration.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                        ),
                        Text(
                          _formatDuration(widget.file.duration),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
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
            StreamBuilder(
                stream: _audioPlayer.isPlayingStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;

                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    color: Theme.of(context).primaryColor,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    iconSize: 40,
                    onPressed: _onPlayPausePressed,
                  );
                }),
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

  void _onPlayPausePressed() async {
    if (_audioPlayer.isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }
}
