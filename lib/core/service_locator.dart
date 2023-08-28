import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/add_song/add_song_state.dart';
import 'package:band_space/user/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // TODO: zrobić inaczej, chyba tak zeby w appce uzywac tylko UserRepository a AuthService uzywac w repozytoriach
  sl.registerSingleton<UserRepository>(
      UserRepository(FirebaseFirestore.instance));

  // services
  sl.registerSingleton<AuthService>(AuthService(FirebaseAuth.instance, sl()));

  // repositories
  sl.registerSingleton<ProjectRepository>(
      ProjectRepository(sl(), FirebaseFirestore.instance));
  sl.registerSingleton<SongRepository>(
      SongRepository(FirebaseFirestore.instance, FirebaseStorage.instance));

  // cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));

  // state
  sl.registerFactory<AddSongState>(() => AddSongState(sl()));
}
