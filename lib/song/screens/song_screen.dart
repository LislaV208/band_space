import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog_state.dart';
import 'package:band_space/song/widgets/song_player.dart';
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

              final currentVersion =
                  versions.isNotEmpty ? versions.first : null;

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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 24,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 800,
                            child: SongPlayer(
                              fileUrl: currentVersion.file.download_url,
                              duration: currentVersion.file.duration,
                            ),
                          ),
                        ),
                      ),
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
