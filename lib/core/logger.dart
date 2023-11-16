import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

class Logger {
  static var _isDebug = kDebugMode;
  static Future<void> initalize({
    required FutureOr<void> Function() appRunner,
    String? environment,
  }) async {
    if (environment == 'dev') {
      _isDebug = true;
    }

    if (_isDebug) {
      log('App start in debug mode');

      await appRunner();
    } else {
      await SentryFlutter.init(
        (options) {
          options.dsn = 'https://cb1968cea622af0903d2b3162a41d2a2@o4506231026155520.ingest.sentry.io/4506231028187136';
          options.environment = environment;
          // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
          // We recommend adjusting this value in production.
          options.tracesSampleRate = 1.0;
        },
        appRunner: appRunner,
      );
    }
  }

  static void setUser(String id, String email) {
    if (_isDebug) {
      log('Logged as user with id: $id, email: $email');
    } else {
      Sentry.configureScope(
        (scope) => scope.setUser(
          SentryUser(
            id: id,
            email: email,
          ),
        ),
      );
    }
  }

  static void captureError(dynamic error) {
    if (_isDebug) {
      log('Captured error: $error');
    } else {
      Sentry.captureException(error);
    }
  }
}
