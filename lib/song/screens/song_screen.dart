import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog_state.dart';
import 'package:band_space/song/widgets/song_player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({super.key, required this.songId});

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
          body: FutureBuilder(
            future: sl.get<SongRepository>().fetchLatestSongVersion(songId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final version = snapshot.data!;

              return Center(
                child: version.file != null
                    ? SongPlayer(fileUrl: version.file!.download_url)
                    : const Text('Brak pliku muzycznego'),
              );
            },
          ),
        );
      },
    );
  }
}
