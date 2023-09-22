import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/utils/context_extensions.dart';

class DeleteProjectDialog extends StatefulWidget {
  const DeleteProjectDialog({super.key});

  @override
  State<DeleteProjectDialog> createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<DeleteProjectDialog> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: AlertDialog(
        title: const Text('Czy na pewno chcesz usunąć projekt?'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const Text(
            'Usunięcie projektu spowoduje usunięcie wszystkich utworzonych w ramach jego utworów oraz wszystkich danych powiązanych z nimi',
          ),
        ),
        actionsAlignment: _isLoading ? MainAxisAlignment.center : MainAxisAlignment.end,
        actions: _isLoading
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          var isDeleted = true;
                          try {
                            await context.read<ProjectRepository>().delete();
                          } on Exception catch (_) {
                            isDeleted = false;
                          }

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
