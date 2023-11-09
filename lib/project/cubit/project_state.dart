import 'package:band_space/song/model/song_model.dart';

class ProjectState {
  final List<SongModel> songs;
  final bool isInitial;

  const ProjectState({
    required this.songs,
    this.isInitial = false,
  });
}
