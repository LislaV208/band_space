import 'package:band_space/song/repository/version_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/repository/user_projects_repository.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/user/repository/user_repository.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // TODO: zrobić inaczej, chyba tak zeby w appce uzywac tylko UserRepository a AuthService uzywac w repozytoriach
  sl.registerSingleton<UserRepository>(UserRepository(FirebaseFirestore.instance));

  // services
  sl.registerSingleton<AuthService>(AuthService(FirebaseAuth.instance, sl()));

  // repositories

  sl.registerFactory<UserProjectsRepository>(() {
    final auth = sl<AuthService>();
    final user = auth.user;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    return UserProjectsRepository(userId: user.id, db: FirebaseFirestore.instance);
  });

  sl.registerFactoryParam<ProjectRepository, String, void>(
    (projectId, _) {
      final auth = sl<AuthService>();
      final user = auth.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      return ProjectRepository(
        projectId: projectId,
        userId: user.id,
        db: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
      );
    },
  );

  sl.registerFactoryParam<SongRepository, String, void>((songId, _) {
    return SongRepository(
      songId: songId,
      db: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
  });

  sl.registerFactoryParam<VersionRepository, String, void>(
    (versionId, _) => VersionRepository(
      versionId: versionId,
      db: FirebaseFirestore.instance,
    ),
  );

  // cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
}
