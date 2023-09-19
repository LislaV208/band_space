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
        title: const Text('Poprzednie wersje'),
      ),
      body: StreamBuilder(
        stream: sl<SongRepository>(param1: songId).getVersionHistory(),
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

              return _VersionHistoryListTile(
                version: version,
                songId: songId,
                isCurrent: isCurrent,
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

class _VersionHistoryListTile extends StatelessWidget {
  const _VersionHistoryListTile({
    required this.version,
    required this.songId,
    required this.isCurrent,
  });

  final String songId;
  final SongVersionModel version;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informacje',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wersja ${version.version_number}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (version.timestamp != null)
                    Text(
                      DateFormat('HH:mm dd/MM/yyyy').format(
                        version.timestamp!,
                      ),
                    ),
                  if (version.comment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                          text: 'Komentarz: ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          children: [
                            TextSpan(
                              text: version.comment,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isCurrent
                ? null
                : () async {
                    final navigator = Navigator.of(context);

                    await sl<SongRepository>(param1: songId).setActiveVersion(version.id);

                    navigator.pop();
                  },
            child: Text(isCurrent ? 'Aktywna' : 'Ustaw jako aktywną'),
          )
        ],
      ),
    );
  }
}
