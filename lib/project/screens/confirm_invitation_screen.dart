import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:band_space/project/exceptions/project_exceptions.dart';
import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/widgets/app_future_builder.dart';

class ConfirmInvitationScreen extends StatefulWidget {
  const ConfirmInvitationScreen({super.key});

  @override
  State<ConfirmInvitationScreen> createState() => _ConfirmInvitationScreenState();
}

class _ConfirmInvitationScreenState extends State<ConfirmInvitationScreen> {
  var _loading = false;

  late Future<ProjectModel> _projectFuture;

  @override
  void initState() {
    super.initState();

    _projectFuture = context.read<ProjectRepository>().get().first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppFutureBuilder(
          future: _projectFuture,
          builder: (context, project) {
            if (_loading) return const CircularProgressIndicator();
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

                            var message = 'Dołączono do projektu ${project.name}';
                            try {
                              await context.read<ProjectRepository>().addMember();
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
                              message: 'Odrzucono zaproszenie do projektu ${project.name}',
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
          noDataText: 'Nieprawidłowe zaprosznie',
        ),
      ),
    );
  }
}
