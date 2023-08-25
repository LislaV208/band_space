import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/widgets/app_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: sl.get<ProjectRepository>().fetchProject(projectId),
          builder: (context, snapshot) {
            final project = snapshot.data;
            if (project == null) return const SizedBox();

            return Text(project.name);
          },
        ),
      ),
      body: AppFutureBuilder(
        future: sl.get<SongRepository>().fetchSongs(projectId),
        builder: (context, songs) {
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
                    DateFormat('dd-MM-yyyy HH:mm').format(song.created_at),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                );
              },
            ).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(
            'add_song',
            pathParameters: {
              'project_id': projectId,
            },
          );
        },
        label: const Text('Nowy utwór'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
