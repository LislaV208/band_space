import 'package:band_space/song/screens/delete_song/delete_song_dialog_state.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteSongDialog extends StatelessWidget {
  const DeleteSongDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeleteSongDialogState>();
    final loading = state.deleteInProgress;

    return AlertDialog(
      title: const Text('Czy na pewno chcesz usunąć utwór?'),
      content: const Text(
        'Usunięcie utworu spowoduje usunięcie wszystkich powiązanych z nim plików',
      ),
      actionsAlignment: loading ? MainAxisAlignment.center : MainAxisAlignment.end,
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
                        final isDeleted = await state.deleteSong();
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
    );
  }
}
