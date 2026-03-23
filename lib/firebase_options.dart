
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

  //  android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkj-LdzBif_7EAfKB2Dg7xubYClm0egXg',
    appId: '1:534007286993:android:a8a7c662c98c5fef1a89f0',
    messagingSenderId: '534007286993',
    projectId: 'finance-app-8e9f1',
    storageBucket: 'finance-app-8e9f1.firebasestorage.app',
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
  apiKey: "AIzaSyAiufWmRVNH0hH9EJhJ4qTd8DMVgkkPcqM",
  authDomain: "finance-app-8e9f1.firebaseapp.com",
  projectId: "finance-app-8e9f1",
  storageBucket: "finance-app-8e9f1.firebasestorage.app",
  messagingSenderId: "534007286993",
  appId: "1:534007286993:web:f17fcc993f6a46b21a89f0",
  measurementId: "G-GLGEPKFSKJ"
  );

  //  dùng chung config với Web
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAiufWmRVNH0hH9EJhJ4qTd8DMVgkkPcqM',
    appId: '1:534007286993:web:f17fcc993f6a46b21a89f0',
    messagingSenderId: '534007286993',
    projectId: 'finance-app-8e9f1',
    authDomain: 'finance-app-8e9f1.firebaseapp.com',
    storageBucket: 'finance-app-8e9f1.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );
}

