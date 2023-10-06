import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/delete_project/delete_project_dialog.dart';
import 'package:band_space/project/screens/project_members/project_members_screen.dart';
import 'package:band_space/song/screens/add_song/add_song_screen.dart';
import 'package:band_space/song/screens/add_song/add_song_state.dart';
import 'package:band_space/widgets/app_editable_text.dart';
import 'package:band_space/widgets/app_popup_menu_button.dart';
import 'package:band_space/widgets/app_stream_builder.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<ProjectRepository>().get(),
      builder: (context, snapshot) {
        final project = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: AppEditableText(
              project?.name ?? '',
              onEdited: (value) {
                context.read<ProjectRepository>().changeName(value);
              },
            ),
            actions: project != null
                ? [
                    AppPopupMenuButton(
                      itemBuilder: (context) => [
                        AppPopupMenuButtonItem(
                          iconData: Icons.people,
                          text: 'Członkowie',
                          onSelected: () {
                            showModalBottomSheet(
                              context: context,
                              useSafeArea: true,
                              isScrollControlled: true,
                              builder: (_) => Provider.value(
                                value: context.read<ProjectRepository>(),
                                child: const ProjectMembersScreen(),
                              ),
                            );
                          },
                        ),
                        AppPopupMenuButtonItem(
                          iconData: Icons.delete,
                          text: 'Usuń',
                          onSelected: () async {
                            final isDeleted = await showDialog(
                                  context: context,
                                  builder: (_) => Provider.value(
                                    value: context.read<ProjectRepository>(),
                                    child: const DeleteProjectDialog(),
                                  ),
                                ) ??
                                false;

                            if (context.mounted) {
                              if (isDeleted) {
                                context.goNamed('projects');
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ]
                : null,
          ),
          body: AppStreamBuilder(
            stream: context.read<ProjectRepository>().getSongs(),
            builder: (context, songs) {
              return Column(
                children: songs.map(
                  (song) {
                    return ListTile(
                      onTap: () async {
                        context.goNamed(
                          'song',
                          pathParameters: {
                            'project_id': context.read<ProjectRepository>().projectId,
                            'song_id': song.id,
                          },
                        );
                      },
                      leading: const Icon(Icons.music_note),
                      title: Text(
                        song.title,
                      ),
                      subtitle: Text(
                        song.created_at != null ? DateFormat('dd-MM-yyyy HH:mm').format(song.created_at!) : '-',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                ).toList(),
              );
            },
            noDataText: 'Brak utworów',
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              showModalBottomSheet(
                isScrollControlled: true,
                useSafeArea: true,
                context: context,
                builder: (_) {
                  return ChangeNotifierProvider(
                    create: (_) => AddSongState(
                      context.read<ProjectRepository>(),
                    ),
                    child: const AddSongScreen(),
                  );
                },
              );
            },
            label: const Text('Dodaj utwór'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
