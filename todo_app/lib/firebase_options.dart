// File generated manually from your Firebase web configuration.
// For full multi-platform setup, prefer running: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for your app.
///
/// Usage:
/// ```dart
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD93hcvDQp014Gfbu_-_0pHOG1AW16APZE',
    appId: '1:913334197392:web:54c7db61ce1fe3d7b38c15',
    messagingSenderId: '913334197392',
    projectId: 'wk1210-testapp',
    authDomain: 'wk1210-testapp.firebaseapp.com',
    storageBucket: 'wk1210-testapp.firebasestorage.app',
  );

  // These placeholders reuse the web configuration so your project can compile.
  // For real Android/iOS/macOS apps, generate proper options with:
  // flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD93hcvDQp014Gfbu_-_0pHOG1AW16APZE',
    appId: '1:913334197392:web:54c7db61ce1fe3d7b38c15',
    messagingSenderId: '913334197392',
    projectId: 'wk1210-testapp',
    storageBucket: 'wk1210-testapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD93hcvDQp014Gfbu_-_0pHOG1AW16APZE',
    appId: '1:913334197392:web:54c7db61ce1fe3d7b38c15',
    messagingSenderId: '913334197392',
    projectId: 'wk1210-testapp',
    storageBucket: 'wk1210-testapp.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD93hcvDQp014Gfbu_-_0pHOG1AW16APZE',
    appId: '1:913334197392:web:54c7db61ce1fe3d7b38c15',
    messagingSenderId: '913334197392',
    projectId: 'wk1210-testapp',
    storageBucket: 'wk1210-testapp.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD93hcvDQp014Gfbu_-_0pHOG1AW16APZE',
    appId: '1:913334197392:web:54c7db61ce1fe3d7b38c15',
    messagingSenderId: '913334197392',
    projectId: 'wk1210-testapp',
    authDomain: 'wk1210-testapp.firebaseapp.com',
    storageBucket: 'wk1210-testapp.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyD93hcvDQp014Gfbu_-_0pHOG1AW16APZE',
    appId: '1:913334197392:web:54c7db61ce1fe3d7b38c15',
    messagingSenderId: '913334197392',
    projectId: 'wk1210-testapp',
    authDomain: 'wk1210-testapp.firebaseapp.com',
    storageBucket: 'wk1210-testapp.firebasestorage.app',
  );
}
