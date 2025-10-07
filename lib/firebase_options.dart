
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
    apiKey: 'AIzaSyA3h64EomQeWdzs82VWn5xvvn-KbmzZnQA',
    appId: '1:528531549397:web:50ec91988b8bc6beeec65c',
    messagingSenderId: '528531549397',
    projectId: 'testlogin-4767c',
    authDomain: 'testlogin-4767c.firebaseapp.com',
    storageBucket: 'testlogin-4767c.firebasestorage.app',
    measurementId: 'G-5061R786JK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-covwWf3qt5GMBrqRTs_736VBwV6AvgM',
    appId: '1:528531549397:android:556cc048d7fc8360eec65c',
    messagingSenderId: '528531549397',
    projectId: 'testlogin-4767c',
    storageBucket: 'testlogin-4767c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_AKCtXUFbpb7R6_DbJtK56o93VCfzawk',
    appId: '1:528531549397:ios:dc36af644a6f944ceec65c',
    messagingSenderId: '528531549397',
    projectId: 'testlogin-4767c',
    storageBucket: 'testlogin-4767c.firebasestorage.app',
    iosBundleId: '1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your_macos_api_key',
    appId: 'your_macos_app_id',
    messagingSenderId: 'your_macos_messaging_sender_id',
    projectId: 'your_macos_project_id',
    storageBucket: 'your_macos_storage_bucket',
    iosClientId: 'your_macos_client_id',
    iosBundleId: 'your_macos_bundle_id',
  );
}