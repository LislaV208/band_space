import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/add_marker_screen.dart';
import 'package:band_space/song/screens/new_song_version_screen.dart';
import 'package:band_space/song/screens/song_version_history_screen.dart';
import 'package:band_space/song/screens/views/markers_list_view.dart';
import 'package:band_space/song/widgets/song_player.dart';
import 'package:band_space/utils/date_formats.dart';
import 'package:band_space/widgets/app_button_primary.dart';
import 'package:band_space/widgets/app_button_secondary.dart';

class SongVersionView extends StatefulWidget {
  const SongVersionView({
    super.key,
    required this.currentVersion,
  });

  final SongVersionModel? currentVersion;

  @override
  State<SongVersionView> createState() => _SongVersionViewState();
}

class _SongVersionViewState extends State<SongVersionView> {
  final _audioPlayer = sl<AudioPlayerService>();
  late var _currentVersion = widget.currentVersion;

  @override
  void initState() {
    super.initState();

    if (_currentVersion?.file != null) {
      _audioPlayer.setUrl(_currentVersion!.file!.download_url);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_currentVersion != null)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  _currentVersion!.is_current ? 'Aktualna wersja' : 'Archiwalna wersja',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_currentVersion!.timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('Dodano dnia: ${dateTimeFormat.format(_currentVersion!.timestamp!)}'),
                  ),
              ],
            ),
          ),
        Expanded(
          child: _currentVersion != null
              ? Align(
                  child: SizedBox(
                    width: 800,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: MarkersListView(
                            version: _currentVersion!,
                            onSelected: (marker) {
                              _audioPlayer.seek(Duration(seconds: marker.position));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 32,
                          ),
                          child: _currentVersion!.file != null
                              ? SongPlayer(
                                  duration: _currentVersion!.file!.duration,
                                )
                              : const Text('Nie można odtworzyć pliku'),
                        ),
                        AppButtonSecondary(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => AddMarkerScreen(
                                version: _currentVersion!,
                                currentPosition: _audioPlayer.currentPosition.inSeconds,
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
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Visibility.maintain(
                visible: false,
                child: IconButton.filledTonal(
                  onPressed: null,
                  icon: Icon(Icons.history),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
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
                          _onVersionChange(newVersion);
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
                  tooltip: 'Historia wersji',
                  onPressed: () async {
                    if (_currentVersion == null) return;

                    final selectedVersion = await showModalBottomSheet<SongVersionModel>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      enableDrag: false,
                      builder: (_) => MultiProvider(
                        providers: [
                          Provider.value(value: context.read<SongRepository>()),
                        ],
                        child: SongVersionHistoryScreen(
                          activeVersion: _currentVersion!,
                        ),
                      ),
                    );

                    if (selectedVersion != null) {
                      _onVersionChange(selectedVersion);
                    }
                  },
                  icon: const Icon(Icons.history),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _onVersionChange(SongVersionModel newVersion) async {
    await _audioPlayer.stop();

    final file = newVersion.file;
    if (file != null) {
      await _audioPlayer.setUrl(file.download_url);
    }
    await _audioPlayer.seek(Duration.zero);

    if (!mounted) return;

    setState(() {
      _currentVersion = newVersion;
    });
  }
}