import 'package:flutter_dotenv/flutter_dotenv.dart';

late AppConfig config;

class AppConfig {
  String _env = 'dev';

  static const List<String> supportedEnvironments = ['dev', 'prod'];

  Future<void> initialize(String configFilePath) async {
    final envNameFromFile = configFilePath.split('.').last;
    if (AppConfig.supportedEnvironments.contains(envNameFromFile)) {
      await dotenv.load(fileName: configFilePath);
      _env = envNameFromFile;
    } else {
      throw Exception('Not supported environment: $envNameFromFile');
    }
  }

  String get env => _env;
  String get appUrl => dotenv.env['APP_URL'] ?? '';
}
