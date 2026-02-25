// This is a lightweight placeholder so the app can compile/run in demo mode.
// When you're ready, generate real values via FlutterFire CLI and replace this.
//
// Docs: https://firebase.google.com/docs/flutter/setup
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      TargetPlatform.windows => windows,
      TargetPlatform.linux => linux,
      _ => web,
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    measurementId: 'REPLACE_ME',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );
}

