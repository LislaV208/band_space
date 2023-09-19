import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:flutter/material.dart';

class MarkersListView extends StatelessWidget {
  const MarkersListView({
    super.key,
    required this.version,
  });

  final SongVersionModel version;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<VersionRepository>(param1: version.id).getMarkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final markers = snapshot.data!;

        if (markers.isEmpty) {
          return const Center(
            child: Text('Brak znaczników'),
          );
        }

        return Column(
          children: markers.map((item) {
            return ListTile(
              leading: Text(item.position.toString()),
              title: Text(item.name),
            );
          }).toList(),
        );
      },
    );
  }
}
