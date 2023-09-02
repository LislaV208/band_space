import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog_state.dart';
import 'package:band_space/song/screens/new_song_version_screen.dart';
import 'package:band_space/song/screens/views/song_versions_page_view.dart';
import 'package:band_space/widgets/app_button_primary.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({
    super.key,
    required this.projectId,
    required this.songId,
  });

  final String projectId;
  final String songId;

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final _versionsPageController = PageController();

  @override
  void dispose() {
    _versionsPageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl.get<SongRepository>().getSong(widget.songId),
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

        return Scaffold(
          appBar: AppBar(
            title: Text(song.title),
            actions: [
              IconButton(
                onPressed: () async {
                  final isDeleted = await showDialog(
                        context: context,
                        builder: (context) {
                          return ChangeNotifierProvider(
                            create: (context) =>
                                sl.get<DeleteSongDialogState>(),
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
            stream:
                sl.get<SongRepository>().getSongVersionHistory(widget.songId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final versions = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: SongVersionsPageView(
                      controller: _versionsPageController,
                      versions: versions,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: SizedBox(
                      width: 400,
                      child: AppButtonPrimary(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => NewSongVersionScreen(
                              projectId: widget.projectId,
                              songId: widget.songId,
                              onFinished: () {
                                _versionsPageController.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.linear,
                                );
                              },
                            ),
                          );
                        },
                        text: 'Nowa wersja',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
