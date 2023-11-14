import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/router.dart';

void main() async {
  setupServiceLocator();

  usePathUrlStrategy();

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
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
