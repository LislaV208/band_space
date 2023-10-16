import 'package:flutter/material.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/widgets/song_timeline.dart';

class SongPlayer extends StatelessWidget {
  const SongPlayer({
    super.key,
    required this.audioPlayer,
    required this.duration,
    required this.markersStream,
  });

  final AudioPlayerService audioPlayer;
  final int duration;
  final Stream<List<Marker>> markersStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SongTimeline(
          positionStream: audioPlayer.positionStream,
          duration: Duration(seconds: duration),
          onPositionChanged: (position) {
            audioPlayer.seek(position);
          },
          markersStream: markersStream,
          onMarkerTap: (marker) {
            audioPlayer.seek(Duration(seconds: marker.start_position));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Visibility.maintain(
              visible: false,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.loop),
              ),
            ),
            IconButton(
              onPressed: () {
                audioPlayer.rewind();
              },
              icon: const Icon(
                Icons.fast_rewind,
              ),
              iconSize: 40,
              tooltip: 'Przewiń do tyłu',
            ),
            StreamBuilder(
              stream: audioPlayer.isPlayingStream,
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
                  tooltip: isPlaying ? 'Pauza' : 'Odtwórz',
                );
              },
            ),
            IconButton(
              onPressed: () {
                audioPlayer.forward();
              },
              icon: const Icon(
                Icons.fast_forward,
              ),
              iconSize: 40,
              tooltip: 'Przewiń do przodu',
            ),
            StreamBuilder(
              stream: audioPlayer.loopModeStream,
              builder: (context, snapshot) {
                final isLoopMode = snapshot.data ?? false;

                return IconButton(
                  onPressed: () {
                    audioPlayer.toggleLoopMode();
                  },
                  icon: Icon(
                    Icons.loop,
                    color: isLoopMode ? Theme.of(context).colorScheme.primary : null,
                  ),
                  tooltip: isLoopMode ? 'Wyłącz zapętlenie' : 'Włącz zapętlenie',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _onPlayPausePressed() async {
    if (audioPlayer.isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }
}
