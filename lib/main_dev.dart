import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:band_space/app_config.dart';
import 'package:band_space/firebase_options_dev.dart';

import 'main.dart' as runner;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  config = AppConfig();
  await config.initialize('../env.dev');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runner.main();
}
