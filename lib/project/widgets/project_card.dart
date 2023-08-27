import 'package:band_space/project/model/project.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          context.goNamed(
            'project_details',
            pathParameters: {'project_id': project.id},
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(
              const Size.square(120),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder,
                    size: 70,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.name,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
