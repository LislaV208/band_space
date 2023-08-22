import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // services
  sl.registerSingleton<AuthService>(AuthService());

  // cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
}
