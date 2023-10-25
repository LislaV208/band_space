import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/widgets/song_timeline.dart';

class SongPlayer extends StatelessWidget {
  const SongPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = context.read<VersionCubit>().audioPlayer;

    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(maxWidth: 1800),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SongTimeline(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Visibility.maintain(
                visible: false,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.loop),
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
                tooltip: 'Przewiń do tyłu${kIsWeb ? " [←]" : ''}',
              ),
              StreamBuilder(
                  stream: audioPlayer.loadingStream,
                  builder: (context, loadingSnapshot) {
                    final isLoading = loadingSnapshot.data ?? false;

                    return StreamBuilder(
                      stream: audioPlayer.isPlayingStream,
                      builder: (context, isPlayingSnapshot) {
                        final isPlaying = isPlayingSnapshot.data ?? false;

                        return IconButton(
                          icon: isLoading
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                          color: Theme.of(context).primaryColor,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                          iconSize: 40,
                          onPressed: () {
                            if (audioPlayer.isPlaying) {
                              audioPlayer.pause();
                            } else {
                              audioPlayer.play();
                            }
                          },
                          tooltip: (isPlaying ? 'Pauza' : 'Odtwórz') + (kIsWeb ? ' [Spacja]' : ''),
                        );
                      },
                    );
                  }),
              IconButton(
                onPressed: () {
                  audioPlayer.forward();
                },
                icon: const Icon(
                  Icons.fast_forward,
                ),
                iconSize: 40,
                tooltip: 'Przewiń do przodu${kIsWeb ? " [→]" : ''}',
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
      ),
    );
  }
}
