import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/widgets/app_future_builder.dart';
import 'package:flutter/material.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({super.key, required this.songId});

  final String songId;

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: sl.get<SongRepository>().fetchSong(songId),
        builder: (context, song) {
          return Scaffold(
            appBar: AppBar(
              title: Text(song.title),
            ),
            body: Center(
              child: Text('elko morelko'),
            ),
          );
        });
  }
}
