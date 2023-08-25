import 'package:band_space/data_sources/firebase_data_source.dart';

import 'package:band_space/song/model/song.dart';
import 'package:file_picker/file_picker.dart';

class SongRepository {
  SongRepository(this.dataSource);

  final FirebaseDataSource dataSource;

  Future<List<Song>> fetchSongs(String projectId) async {
    return dataSource.fetchSongs(projectId);
  }

  Future<Song> fetchSong(String songId) async {
    return dataSource.fetchSong(songId);
  }

  Future<String> addSong(
    String projectId,
    String title,
    PlatformFile file,
  ) async {
    return dataSource.addSong(projectId, title, file);
  }
}
