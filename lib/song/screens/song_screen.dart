import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/widgets/song_player.dart';
import 'package:band_space/widgets/app_future_builder.dart';
import 'package:flutter/material.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key, required this.songId});

  final String songId;

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
      future: sl.get<SongRepository>().fetchSong(widget.songId),
      builder: (context, song) {
        return Scaffold(
          appBar: AppBar(
            title: Text(song.title),
          ),
          body: Center(
            child: SongPlayer(fileUrl: song.file_url),
          ),
        );
      },
    );
  }
}
