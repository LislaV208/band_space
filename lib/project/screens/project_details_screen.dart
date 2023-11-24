import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:band_space/project/cubit/project_cubit.dart';
import 'package:band_space/project/cubit/project_state.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/delete_project/delete_project_dialog.dart';
import 'package:band_space/project/screens/project_members/project_members_screen.dart';
import 'package:band_space/project/widgets/songs_list.dart';
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

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                child: SongsList(songs: songs),
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
