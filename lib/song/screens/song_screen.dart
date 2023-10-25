import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/cubit/version_cubit.dart';
import 'package:band_space/song/cubit/version_state.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog.dart';
import 'package:band_space/song/screens/views/version_view.dart';
import 'package:band_space/widgets/app_editable_text.dart';
import 'package:band_space/widgets/app_stream_builder.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<SongRepository>().get(),
      builder: (context, snapshot) {
        final song = snapshot.data;

        if (song != null) {
          log('Song current version id: ${song.current_version_id}');
        }

        return Scaffold(
          appBar: AppBar(
            title: song != null
                ? AppEditableText(
                    song.title,
                    onEdited: (value) {
                      context.read<SongRepository>().changeTitle(value);
                    },
                  )
                : null,
            actions: song != null
                ? [
                    IconButton(
                      onPressed: () async {
                        final isDeleted = await showDialog(
                              context: context,
                              builder: (_) => Provider.value(
                                value: context.read<SongRepository>(),
                                child: const DeleteSongDialog(),
                              ),
                            ) ??
                            false;

                        //TODO: po usunięciu nie robi pop. poprawić

                        if (context.mounted) {
                          print('mounted');
                          if (isDeleted) {
                            print('POP!');
                            context.pop();
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ]
                : null,
          ),
          body: song == null
              ? Center(
                  child: snapshot.hasError ? const Text('Zjebalo sie') : const CircularProgressIndicator(),
                )
              : AppStreamBuilder(
                  stream: sl<VersionRepository>(param1: song.current_version_id).get(),
                  builder: (context, currentVersion) {
                    return Provider(
                      create: (context) => VersionCubit(
                        const VersionState(selectedComment: null),
                        currentVersion: currentVersion,
                        versionRepository: sl<VersionRepository>(param1: currentVersion.id),
                        audioPlayer: sl<AudioPlayerService>(),
                      ),
                      dispose: (context, cubit) => cubit.dispose(),
                      child: const VersionView(),
                    );
                  },
                ),
        );
      },
    );
  }
}
