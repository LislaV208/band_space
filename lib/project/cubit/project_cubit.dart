import 'dart:async';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';

import 'package:band_space/project/cubit/project_state.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/song/model/song_upload_data.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final ProjectRepository projectRepository;

  StreamSubscription<List<SongModel>>? _songsSub;

  ProjectCubit({
    required this.projectRepository,
  }) : super(
          const ProjectState(
            isInitial: true,
            songs: [],
          ),
        ) {
    _songsSub = projectRepository.getSongs().listen(_onSongsUpdate);
  }

  void addSong() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Wybierz plik do wysłania',
      withData: true,
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes != null) {
        final mimeType = lookupMimeType('', headerBytes: bytes);

        projectRepository.addSong(
          SongUploadData(
            title: file.name,
            file: SongUploadFile(
              name: file.name,
              extension: file.extension ?? '',
              data: bytes,
              size: file.size,
              mimeType: mimeType ?? '',
            ),
          ),
        );
      } else {
        log('Zjebało sie!');
      }
    }
  }

  void _onSongsUpdate(List<SongModel> songs) {
    emit(ProjectState(songs: songs));
  }

  void dispose() {
    _songsSub?.cancel();
  }
}
