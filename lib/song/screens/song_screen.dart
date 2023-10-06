import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:band_space/comments/comments_screen.dart';
import 'package:band_space/comments/repository/comments_repository.dart';
import 'package:band_space/comments/repository/song_comments_repository.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/delete_song/delete_song_dialog.dart';
import 'package:band_space/song/screens/views/song_view.dart';
import 'package:band_space/widgets/app_editable_text.dart';

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
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => Provider<CommentsRepository>.value(
                            value: context.read<SongCommentsRepository>(),
                            child: CommentsScreen(title: 'Utwór "${song.title}"'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                    ),
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

                        if (context.mounted) {
                          if (isDeleted) {
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
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SongView(
                  versionId: song.current_version_id,
                ),
        );
      },
    );
  }
}
