import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/utils/context_extensions.dart';

class DeleteSongDialog extends StatefulWidget {
  const DeleteSongDialog({super.key});

  @override
  State<DeleteSongDialog> createState() => _DeleteSongDialogState();
}

class _DeleteSongDialogState extends State<DeleteSongDialog> {
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Czy na pewno chcesz usunąć utwór?'),
      content: const Text(
        'Usunięcie utworu spowoduje usunięcie wszystkich powiązanych z nim plików',
      ),
      actionsAlignment: _loading ? MainAxisAlignment.center : MainAxisAlignment.end,
      actions: [
        if (_loading)
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(),
          )
        else ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: _loading
                ? null
                : () async {
                    setState(() {
                      _loading = true;
                    });

                    var isDeleted = true;

                    try {
                      await context.read<SongRepository>().delete();
                    } on Exception catch (e) {
                      log(e.toString());
                      isDeleted = false;
                    }

                    if (!mounted) return;

                    if (!isDeleted) {
                      context.showErrorSnackbar();
                    }

                    Navigator.of(context).pop(isDeleted);
                  },
            child: const Text('Usuń'),
          ),
        ],
      ],
    );
  }
}
