import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/widgets/song_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SongVersionView extends StatelessWidget {
  const SongVersionView({super.key, required this.version});

  final SongVersionModel version;

  @override
  Widget build(BuildContext context) {
    if (version.file == null) {
      return const Center(
        child: Text('Brak wersji utworu'),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Wersja ${version.version_number}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Card(
              child: SongPlayer(
                fileUrl: version.file!.download_url,
                duration: version.file!.duration,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('HH:mm dd.MM.yyyy').format(version.timestamp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
