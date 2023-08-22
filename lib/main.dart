import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/firebase_options.dart';
import 'package:band_space/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupServiceLocator();

  runApp(
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<AuthCubit>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'BandSpace',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.lightBlue,
        ),
        routerConfig: router,
      ),
    );
  }
}
