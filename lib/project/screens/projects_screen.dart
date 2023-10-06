import 'package:flutter/material.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/repository/user_projects_repository.dart';
import 'package:band_space/project/screens/add_project_screen.dart';
import 'package:band_space/project/widgets/project_card.dart';
import 'package:band_space/widgets/app_stream_builder.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projekty'),
      ),
      body: AppStreamBuilder(
        stream: sl<UserProjectsRepository>().getProjects(),
        builder: (context, projects) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: projects.map((project) => ProjectCard(project: project)).toList(),
              ),
            ),
          );
        },
        noDataText: 'Brak projektów',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const AddProjectScreen(),
          );
        },
        label: const Text('Nowy projekt'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
