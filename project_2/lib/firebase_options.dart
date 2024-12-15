// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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
    apiKey: 'AIzaSyCUjW2ubYA7isWvadSnoS6e0gxnXU4ob5E',
    appId: '1:436564629857:web:76134e5ca7a7e1911acd20',
    messagingSenderId: '436564629857',
    projectId: 'project-2-mobileappdev',
    authDomain: 'project-2-mobileappdev.firebaseapp.com',
    storageBucket: 'project-2-mobileappdev.firebasestorage.app',
    measurementId: 'G-BVPTL5HC7T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDM1lcJGEdlX_A4jJsA_UgXH8ck1ifIk2A',
    appId: '1:436564629857:android:031cc10bbbb733b11acd20',
    messagingSenderId: '436564629857',
    projectId: 'project-2-mobileappdev',
    storageBucket: 'project-2-mobileappdev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgOtBQEcC0fC02ZjqXK9WGDqfUhOSjKUs',
    appId: '1:436564629857:ios:e787503f2eabe2611acd20',
    messagingSenderId: '436564629857',
    projectId: 'project-2-mobileappdev',
    storageBucket: 'project-2-mobileappdev.firebasestorage.app',
    iosBundleId: 'com.example.project2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgOtBQEcC0fC02ZjqXK9WGDqfUhOSjKUs',
    appId: '1:436564629857:ios:e787503f2eabe2611acd20',
    messagingSenderId: '436564629857',
    projectId: 'project-2-mobileappdev',
    storageBucket: 'project-2-mobileappdev.firebasestorage.app',
    iosBundleId: 'com.example.project2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCUjW2ubYA7isWvadSnoS6e0gxnXU4ob5E',
    appId: '1:436564629857:web:d562e6a9ec22b2041acd20',
    messagingSenderId: '436564629857',
    projectId: 'project-2-mobileappdev',
    authDomain: 'project-2-mobileappdev.firebaseapp.com',
    storageBucket: 'project-2-mobileappdev.firebasestorage.app',
    measurementId: 'G-900ZZN2KH2',
  );
}
