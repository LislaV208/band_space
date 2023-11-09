import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/file_storage/upload_task_manager.dart';
import 'package:band_space/project/cubit/project_cubit.dart';
import 'package:band_space/project/cubit/project_state.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/delete_project/delete_project_dialog.dart';
import 'package:band_space/project/screens/project_members/project_members_screen.dart';
import 'package:band_space/project/widgets/uploading_song_list_tile.dart';
import 'package:band_space/widgets/app_editable_text.dart';
import 'package:band_space/widgets/app_popup_menu_button.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //TODO:  usunąć wykorzystanie repository bezpośrednio w UI
      stream: context.read<ProjectRepository>().get(),
      builder: (context, snapshot) {
        final project = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: AppEditableText(
              project?.name ?? '',
              onEdited: (value) {
                //TODO:  usunąć wykorzystanie repository bezpośrednio w UI
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
          body: BlocBuilder<ProjectCubit, ProjectState>(
            builder: (context, state) {
              if (state.isInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final songs = state.songs;

              if (songs.isEmpty) {
                return const Center(
                  child: Text('Brak utworów'),
                );
              }

              return Column(
                children: songs.map(
                  (song) {
                    final uploadManager = sl<UploadTaskManager>();
                    final uploadTask = uploadManager.getUploadTask(song.current_version_id);

                    if (uploadTask != null) {
                      return UploadingSongListTile(song: song, uploadTask: uploadTask);
                    } else if (song.upload_in_progress) {
                      // utwór nie został zuploadowany, ale nie mamy dostępu do danych uploadu - pomijamy
                      return const SizedBox();
                    }

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
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.read<ProjectCubit>().addSong(),
            label: const Text('Dodaj utwór'),
            icon: const Icon(Icons.upload_file_rounded),
          ),
        );
      },
    );
  }
}
