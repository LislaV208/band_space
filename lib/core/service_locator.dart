import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:band_space/audio/audio_player_service.dart';
import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/file_storage/remote_song_file_storage.dart';
import 'package:band_space/file_storage/upload_task_manager.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/repository/user_projects_repository.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/user/repository/user_repository.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerFactory<AudioPlayerService>(() => AudioPlayerService());

  // TODO: zrobić inaczej, chyba tak zeby w appce uzywac tylko UserRepository a AuthService uzywac w repozytoriach
  sl.registerSingleton<UserRepository>(UserRepository(FirebaseFirestore.instance));

  // services
  sl.registerSingleton<AuthService>(AuthService(FirebaseAuth.instance, sl()));

  // repositories
  sl.registerFactory<UserProjectsRepository>(
    () => UserProjectsRepository(userId: _getUserId(), db: FirebaseFirestore.instance),
  );

  sl.registerSingleton<UploadTaskManager>(UploadTaskManager());
  sl.registerSingleton<RemoteSongFileStorage>(
    RemoteSongFileStorage(storage: FirebaseStorage.instance, uploadTaskManager: sl()),
  );

  sl.registerFactoryParam<ProjectRepository, String, void>(
    (projectId, _) => ProjectRepository(
      projectId: projectId,
      userId: _getUserId(),
      db: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      remoteSongFileStorage: sl(),
    ),
  );

  sl.registerFactoryParam<SongRepository, String, void>(
    (songId, _) => SongRepository(
      songId: songId,
      db: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ),
  );

  sl.registerFactoryParam<VersionRepository, String, void>(
    (versionId, _) => VersionRepository(
      versionId: versionId,
      userId: _getUserId(),
      db: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ),
  );

  // cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
}

String _getUserId() {
  final auth = sl<AuthService>();
  final user = auth.user;

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return user.id;
}
