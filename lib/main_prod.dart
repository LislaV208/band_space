import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:band_space/app_config.dart';
import 'package:band_space/core/logger.dart';
import 'package:band_space/firebase_options_prod.dart';

import 'main.dart' as runner;

Future<void> main() async {
  await Logger.initalize(
    environment: 'prod',
    appRunner: () async {
      config = AppConfig();
      await config.initialize('../.env.prod');
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await runner.main();
    },
  );
}
