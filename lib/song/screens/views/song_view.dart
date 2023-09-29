import 'package:flutter/material.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/song/screens/views/song_version_view.dart';

class SongView extends StatelessWidget {
  const SongView({
    super.key,
    required this.versionId,
  });

  final String versionId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: StreamBuilder(
          stream: sl<VersionRepository>(param1: versionId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SongVersionView(
              currentVersion: snapshot.data,
            );
          }),
    );
  }
}
