import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/project/screens/delete_project/delete_project_dialog_state.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteProjectDialog extends StatelessWidget {
  const DeleteProjectDialog({super.key, required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeleteProjectDialogState>();
    final loading = state.deleteInProgress;

    return WillPopScope(
      onWillPop: () async => !loading,
      child: AlertDialog(
        title: const Text('Czy na pewno chcesz usunąć projekt?'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const Text(
            'Usunięcie projektu spowoduje usunięcie wszystkich utworzonych w ramach jego utworów oraz wszystkich danych powiązanych z nimi',
          ),
        ),
        actionsAlignment:
            loading ? MainAxisAlignment.center : MainAxisAlignment.end,
        actions: loading
            ? [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(),
                ),
              ]
            : [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Anuluj'),
                ),
                FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final isDeleted = await state.deleteProject(project);
                          if (context.mounted) {
                            if (!isDeleted) {
                              context.showErrorSnackbar();
                            }
                            Navigator.of(context).pop(isDeleted);
                          }
                        },
                  child: const Text('Usuń'),
                ),
              ],
      ),
    );
  }
}
