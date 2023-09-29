import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/utils/date_formats.dart';

class SongVersionHistoryScreen extends StatefulWidget {
  const SongVersionHistoryScreen({
    super.key,
    required this.activeVersion,
  });

  final SongVersionModel activeVersion;

  @override
  State<SongVersionHistoryScreen> createState() => _SongVersionHistoryScreenState();
}

class _SongVersionHistoryScreenState extends State<SongVersionHistoryScreen> {
  late var _activeVersion = widget.activeVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia wersji'),
      ),
      body: StreamBuilder(
        stream: context.read<SongRepository>().getVersionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            log(snapshot.error.toString());

            return const Center(
              child: Text('Wystąpił błąd'),
            );
          }

          final versions = snapshot.data!;

          return ListView.separated(
            itemBuilder: (context, index) {
              final version = versions[index];

              final isActive = version.id == _activeVersion.id;

              return _VersionHistoryListTile(
                version: version,
                isActive: isActive,
                canDelete: versions.length > 1,
                onCurrentVersionDelete: () async {
                  final currentVersion = await context.read<SongRepository>().fetchCurrentVersion();

                  setState(() {
                    _activeVersion = currentVersion;
                  });
                },
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
    required this.isActive,
    required this.canDelete,
    required this.onCurrentVersionDelete,
  });

  final SongVersionModel version;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onCurrentVersionDelete;

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
                    version.is_current ? 'Aktualna' : 'Archiwalna',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isActive ? FontWeight.bold : null,
                          decoration: isActive ? TextDecoration.underline : null,
                        ),
                  ),
                  if (version.timestamp != null)
                    Text(
                      dateTimeFormat.format(version.timestamp!),
                    ),
                  if (version.comment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                          text: 'Co nowego: ',
                          style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.w600),
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
            onPressed: isActive
                ? null
                : () {
                    Navigator.of(context).pop(version);
                  },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 60),
              child: Text(
                isActive ? 'Aktywna' : 'Przywróć',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (canDelete)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () async {
                  await sl<VersionRepository>(param1: version.id).delete();

                  if (version.is_current) {
                    onCurrentVersionDelete();
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ),
        ],
      ),
    );
  }
}
