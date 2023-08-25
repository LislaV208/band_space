import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/add_project_screen.dart';
import 'package:band_space/project/widgets/project_card.dart';
import 'package:band_space/widgets/app_future_builder.dart';
import 'package:flutter/material.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projekty'),
      ),
      body: AppFutureBuilder(
        future: sl.get<ProjectRepository>().fetchProjects(),
        builder: (context, projects) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: projects
                    .map((project) => ProjectCard(project: project))
                    .toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            builder: (context) => const AddProjectScreen(),
          );

          setState(() {
            // print('BOINK!');
          });
        },
        label: const Text('Nowy projekt'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
