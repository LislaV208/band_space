import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/delete_project/delete_project_dialog.dart';
import 'package:band_space/project/screens/project_members/project_members_screen.dart';
import 'package:band_space/song/screens/add_song/add_song_screen.dart';
import 'package:band_space/song/screens/add_song/add_song_state.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<ProjectRepository>(param1: projectId).getProject(),
      builder: (context, snapshot) {
        final project = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(project?.name ?? ''),
            actions: project != null
                ? [
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useSafeArea: true,
                          isScrollControlled: true,
                          builder: (context) => ProjectMembersScreen(
                            projectId: projectId,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.people,
                      ),
                      tooltip: 'Członkowie',
                    ),
                    IconButton(
                      onPressed: () async {
                        final isDeleted = await showDialog(
                              context: context,
                              builder: (context) => DeleteProjectDialog(projectId: project.id),
                            ) ??
                            false;

                        if (context.mounted) {
                          if (isDeleted) {
                            context.goNamed('projects');
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                      ),
                      tooltip: 'Usuń projekt',
                    ),
                  ]
                : null,
          ),
          body: project == null
              ? const SizedBox()
              : StreamBuilder(
                  stream: sl<ProjectRepository>(param1: projectId).getSongs(),
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

                    final songs = snapshot.data!;

                    if (songs.isEmpty) {
                      return const Center(
                        child: Text('Brak utworów'),
                      );
                    }

                    return Column(
                      children: songs.map(
                        (song) {
                          return ListTile(
                            onTap: () async {
                              context.goNamed(
                                'song',
                                pathParameters: {
                                  'project_id': projectId,
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
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              showModalBottomSheet(
                isScrollControlled: true,
                useSafeArea: true,
                context: context,
                builder: (context) {
                  return ChangeNotifierProvider(
                    create: (context) => AddSongState(
                      sl<ProjectRepository>(param1: projectId),
                    ),
                    child: AddSongScreen(projectId: projectId),
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
