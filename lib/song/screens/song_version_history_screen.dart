import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/song_repository.dart';

class SongVersionHistoryScreen extends StatelessWidget {
  const SongVersionHistoryScreen({
    super.key,
    required this.songId,
    required this.currentVersion,
  });

  final String songId;
  final SongVersionModel currentVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poprzednie wersje'),
      ),
      body: StreamBuilder(
        stream: sl.get<SongRepository>().getSongVersionHistory(songId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Wystąpił błąd'),
            );
          }

          final versions = snapshot.data!;

          return ListView.separated(
            itemBuilder: (context, index) {
              final version = versions[index];

              final isCurrent = version.id == currentVersion.id;

              return ListTile(
                title: Text('Wersja ${version.version_number}'),
                subtitle: version.timestamp != null
                    ? Text(
                        DateFormat('HH:mm dd/MM/yyyy').format(
                          version.timestamp!,
                        ),
                      )
                    : null,
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Informacje',
                ),
                trailing: ElevatedButton(
                  onPressed: isCurrent
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);

                          await sl
                              .get<SongRepository>()
                              .setSongActiveVersion(songId, version.id);

                          navigator.pop();
                        },
                  child: Text(isCurrent ? 'Aktywna' : 'Ustaw jako aktywną'),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: versions.length,
          );
        },
      ),
    );
  }
}
