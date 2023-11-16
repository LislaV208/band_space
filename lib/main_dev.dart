import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:band_space/app_config.dart';
import 'package:band_space/core/logger.dart';
import 'package:band_space/firebase_options_dev.dart';

import 'main.dart' as runner;

void main() async {
  await Logger.initalize(
    environment: 'dev',
    appRunner: () async {
      config = AppConfig();
      await config.initialize('../.env.dev');
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await runner.main();
    },
  );
}
