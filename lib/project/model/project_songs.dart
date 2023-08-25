import 'package:band_space/project/model/project.dart';
import 'package:equatable/equatable.dart';

import 'package:band_space/song/model/song.dart';

class ProjectSongs extends Equatable {
  const ProjectSongs({
    required this.project,
    required this.songs,
  });

  final Project project;
  final List<Song> songs;

  @override
  List<Object> get props => [project, songs];
}
