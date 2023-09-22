import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/add_marker_screen.dart';
import 'package:band_space/song/screens/new_song_version_screen.dart';
import 'package:band_space/song/screens/song_version_history_screen.dart';
import 'package:band_space/song/screens/views/markers_list_view.dart';
import 'package:band_space/song/widgets/song_player.dart';
import 'package:band_space/widgets/app_button_primary.dart';
import 'package:band_space/widgets/app_button_secondary.dart';

class SongView extends StatefulWidget {
  const SongView({
    super.key,
    required this.currentVersion,
  });

  final SongVersionModel? currentVersion;

  @override
  State<SongView> createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  final _audioPlayer = AudioPlayerService();

  late var _currentVersion = widget.currentVersion;

  @override
  void initState() {
    super.initState();

    // _audioPlayer.initialize(song!.current_version!.file!.download_url);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: _currentVersion != null
                ? Align(
                    child: SizedBox(
                      width: 800,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MarkersListView(
                            version: _currentVersion!,
                            onSelected: (marker) {
                              _audioPlayer.seek(Duration(seconds: marker.position));
                            },
                          ),
                          Text('Wersja ${_currentVersion!.version_number}'),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 24,
                            ),
                            child: _currentVersion!.file != null
                                ? SongPlayer(
                                    audioPlayer: _audioPlayer,
                                    duration: _currentVersion!.file!.duration,
                                  )
                                : const Text('Nie można odtworzyć pliku'),
                          ),
                          AppButtonSecondary(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => AddMarkerScreen(
                                  version: _currentVersion!,
                                ),
                              );
                            },
                            text: 'Dodaj znacznik',
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility.maintain(
                  visible: false,
                  child: IconButton.filledTonal(
                    onPressed: () {},
                    icon: Icon(Icons.history),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: AppButtonPrimary(
                        onPressed: () async {
                          final newVersion = await showModalBottomSheet<SongVersionModel>(
                            context: context,
                            builder: (_) {
                              return Provider.value(
                                value: context.read<SongRepository>(),
                                child: const NewSongVersionScreen(),
                              );
                            },
                          );

                          if (newVersion != null) {
                            setState(() {
                              _currentVersion = newVersion;
                            });
                          }
                        },
                        text: 'Dodaj wersję',
                      ),
                    ),
                  ),
                ),
                Visibility.maintain(
                  visible: _currentVersion != null,
                  child: IconButton.filledTonal(
                    tooltip: 'Poprzednie wersje',
                    onPressed: () async {
                      if (_currentVersion == null) return;

                      final selectedVersion = await showModalBottomSheet<SongVersionModel>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        enableDrag: false,
                        builder: (_) => Provider.value(
                          value: context.read<SongRepository>(),
                          child: SongVersionHistoryScreen(
                            currentVersion: _currentVersion!,
                          ),
                        ),
                      );

                      if (selectedVersion != null) {
                        setState(() {
                          _currentVersion = selectedVersion;
                        });
                      }
                    },
                    icon: const Icon(Icons.history),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
