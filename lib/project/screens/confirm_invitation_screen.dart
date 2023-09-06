import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/exceptions/project_exceptions.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmInvitationScreen extends StatefulWidget {
  const ConfirmInvitationScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<ConfirmInvitationScreen> createState() =>
      _ConfirmInvitationScreenState();
}

class _ConfirmInvitationScreenState extends State<ConfirmInvitationScreen> {
  var _loading = false;

  late Future<ProjectModel> _projectFuture;

  @override
  void initState() {
    super.initState();

    _projectFuture =
        sl.get<ProjectRepository>().getProject(widget.projectId).first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _projectFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done || _loading) {
              return const CircularProgressIndicator();
            }

            final project = snapshot.data;

            if (project == null) {
              return const Text('Nieprawidłowe zaprosznie');
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${project.name} - zaproszenie do współpracy',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Czy chcesz dołączyć do projektu?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: () async {
                            setState(() {
                              _loading = true;
                            });

                            var message =
                                'Dołączono do projektu ${project.name}';
                            try {
                              await sl
                                  .get<ProjectRepository>()
                                  .addMemberToProject(project.id);
                            } on DuplicateProjectMemberException catch (_) {
                              message = 'Jesteś już członkiem tego projektu';
                            }

                            if (!mounted) return;

                            context.goNamed(
                              'project_details',
                              pathParameters: {
                                'project_id': project.id,
                              },
                            );

                            context.showSnackbar(message);
                          },
                          child: const Text('Dołącz'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.goNamed('projects');
                            context.showErrorSnackbar(
                              message:
                                  'Odrzucono zaproszenie do projektu ${project.name}',
                            );
                          },
                          child: const Text('Odrzuć'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
