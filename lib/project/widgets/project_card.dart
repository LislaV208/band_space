import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/delete_project/delete_project_dialog.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/widgets/app_editable_text.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project});

  final ProjectModel project;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late var _projectRepository = sl<ProjectRepository>(param1: widget.project.id);

  var _isEditing = false;

  @override
  void didUpdateWidget(ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.project.id != oldWidget.project.id) {
      _projectRepository = sl<ProjectRepository>(param1: widget.project.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _showContextMenu(details.globalPosition),
      child: Card(
        child: InkWell(
          onTap: () {
            context.goNamed(
              'project_details',
              pathParameters: {'project_id': widget.project.id},
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(
                const Size.square(125),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder, size: 70),
                    AppEditableText(
                      widget.project.name,
                      onEdited: (value) {
                        _projectRepository.changeName(value);
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      editable: _isEditing,
                      autofocus: _isEditing,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(Offset position) {
    context.showContextMenu(
      globalPosition: position,
      items: [
        PopupMenuItem(
          onTap: () {
            setState(() {
              _isEditing = true;
            });
          },
          child: const Text('Zmień nazwę'),
        ),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Provider.value(
                value: _projectRepository,
                child: const DeleteProjectDialog(),
              ),
            );
          },
          child: const Text('Usuń'),
        ),
      ],
    );
  }
}
