import 'package:band_space/song/screens/add_marker_screen.dart';
import 'package:band_space/widgets/app_button_secondary.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog_state.dart';
import 'package:band_space/song/screens/new_song_version_screen.dart';
import 'package:band_space/song/screens/song_version_history_screen.dart';
import 'package:band_space/song/widgets/song_player.dart';
import 'package:band_space/widgets/app_button_primary.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({
    super.key,
    required this.projectId,
    required this.songId,
  });

  final String projectId;
  final String songId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl.get<SongRepository>().getSong(songId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(
            child: SizedBox(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Wystąpił błąd'),
          );
        }

        final song = snapshot.data!;

        final versionText = song.active_version != null ? 'v${song.active_version!.version_number}' : '';

        return Scaffold(
          appBar: AppBar(
            title: Text('${song.title} $versionText'),
            actions: [
              IconButton(
                onPressed: () async {
                  final isDeleted = await showDialog(
                        context: context,
                        builder: (context) {
                          return ChangeNotifierProvider(
                            create: (context) => sl.get<DeleteSongDialogState>(),
                            child: DeleteSongDialog(song: song),
                          );
                        },
                      ) ??
                      false;

                  if (context.mounted) {
                    if (isDeleted) {
                      context.pop();
                    }
                  }
                },
                icon: const Icon(
                  Icons.delete,
                ),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: sl.get<SongRepository>().getSongVersionHistory(songId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final versions = snapshot.data!;

              final currentVersion = versions.isNotEmpty ? versions.first : null;

              return SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Align(
                        child: Text(
                          song.state.toString(),
                        ),
                      ),
                    ),
                    if (currentVersion != null)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 24,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 800,
                                child: currentVersion.file != null
                                    ? SongPlayer(
                                        fileUrl: currentVersion.file!.download_url,
                                        duration: currentVersion.file!.duration,
                                      )
                                    : const Text('Nie można odtworzyć pliku'),
                              ),
                            ),
                          ),
                          AppButtonSecondary(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => AddMarkerScreen(
                                  songId: songId,
                                  version: currentVersion,
                                ),
                              );
                            },
                            text: 'Dodaj znacznik',
                          ),
                        ],
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
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return NewSongVersionScreen(
                                          projectId: projectId,
                                          songId: song.id,
                                          onFinished: () {},
                                        );
                                      },
                                    );
                                  },
                                  text: 'Dodaj wersję',
                                ),
                              ),
                            ),
                          ),
                          Visibility.maintain(
                            visible: song.active_version != null,
                            child: IconButton.filledTonal(
                              tooltip: 'Poprzednie wersje',
                              onPressed: () {
                                if (song.active_version == null) return;
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  enableDrag: false,
                                  builder: (context) => SongVersionHistoryScreen(
                                    songId: songId,
                                    currentVersion: song.active_version!,
                                  ),
                                );
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
            },
          ),
        );
      },
    );
  }
}
