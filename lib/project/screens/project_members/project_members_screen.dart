import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/project_members/widgets/share_project_widget.dart';

class ProjectMembersScreen extends StatelessWidget {
  const ProjectMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Członkowie projektu'),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: context.read<ProjectRepository>().fetchMembers(),
            builder: (context, snapshot) {
              final members = snapshot.data ?? [];

              return Expanded(
                child: ListView(
                  children: members
                      .map((member) => ListTile(
                            title: Text(member.email),
                          ))
                      .toList(),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 42),
            child: ShareProjectWidget(),
          ),
        ],
      ),
    );
  }
}
