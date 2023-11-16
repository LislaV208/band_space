import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPnc38EfmpA43rdK_iQPj47VWB7xCk8eQ',
    appId: '1:712649351484:web:28797857c17d8a9b96fe39',
    messagingSenderId: '712649351484',
    projectId: 'band-space-317b6',
    authDomain: 'band-space-317b6.firebaseapp.com',
    storageBucket: 'band-space-317b6.appspot.com',
    measurementId: 'G-BSLKST7YED',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBs-sCpJwnUmmSwsjvFe54hz65xHUu84j0',
    appId: '1:712649351484:android:757968814606b15e96fe39',
    messagingSenderId: '712649351484',
    projectId: 'band-space-317b6',
    storageBucket: 'band-space-317b6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbxxXwstcAuMMkIChA7Yt6oQzK3zrg6ms',
    appId: '1:712649351484:ios:5e0c055165c2553a96fe39',
    messagingSenderId: '712649351484',
    projectId: 'band-space-317b6',
    storageBucket: 'band-space-317b6.appspot.com',
    iosBundleId: 'lislav.bandspace',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAbxxXwstcAuMMkIChA7Yt6oQzK3zrg6ms',
    appId: '1:712649351484:ios:632f1ee21edecf8596fe39',
    messagingSenderId: '712649351484',
    projectId: 'band-space-317b6',
    storageBucket: 'band-space-317b6.appspot.com',
    iosClientId: '712649351484-4vvo9fvm6t2vpakkqc3k55frunuoi1ar.apps.googleusercontent.com',
    iosBundleId: 'com.example.bandSpace.RunnerTests',
  );
}
