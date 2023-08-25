import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/data_sources/firebase_data_source.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // services
  sl.registerSingleton<AuthService>(AuthService());

  // data sources
  sl.registerSingleton<FirebaseDataSource>(
    FirebaseDataSource(
      sl(),
      FirebaseFirestore.instance,
      FirebaseStorage.instance,
    ),
  );

  // repositories
  sl.registerSingleton<ProjectRepository>(ProjectRepository(sl()));
  sl.registerSingleton<SongRepository>(SongRepository(sl()));

  // cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
}
