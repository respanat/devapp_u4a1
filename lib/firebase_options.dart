// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDAQzMHvnIoBTGmOFtWcVvZXyhtA7l3QJA',
    appId: '1:452769889420:web:6cc3c4d62a1cc45d890fa9',
    messagingSenderId: '452769889420',
    projectId: 'vehiculosapp-37a3f',
    authDomain: 'vehiculosapp-37a3f.firebaseapp.com',
    databaseURL: 'https://vehiculosapp-37a3f-default-rtdb.firebaseio.com',
    storageBucket: 'vehiculosapp-37a3f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaig5gG3UciV5INpgqs5J4z8YeIarEv00',
    appId: '1:452769889420:android:a44eafa232a2298e890fa9',
    messagingSenderId: '452769889420',
    projectId: 'vehiculosapp-37a3f',
    databaseURL: 'https://vehiculosapp-37a3f-default-rtdb.firebaseio.com',
    storageBucket: 'vehiculosapp-37a3f.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDAQzMHvnIoBTGmOFtWcVvZXyhtA7l3QJA',
    appId: '1:452769889420:web:14f227b6c0ebb4c8890fa9',
    messagingSenderId: '452769889420',
    projectId: 'vehiculosapp-37a3f',
    authDomain: 'vehiculosapp-37a3f.firebaseapp.com',
    databaseURL: 'https://vehiculosapp-37a3f-default-rtdb.firebaseio.com',
    storageBucket: 'vehiculosapp-37a3f.firebasestorage.app',
  );
}
