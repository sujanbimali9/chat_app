// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCBAnLyjxUm129cHRxxMhzVE3SKk9ygBkw',
    appId: '1:1065966968008:web:0e350b2fae63517e83d9fd',
    messagingSenderId: '1065966968008',
    projectId: 'chatapp-54837',
    authDomain: 'chatapp-54837.firebaseapp.com',
    storageBucket: 'chatapp-54837.appspot.com',
    measurementId: 'G-R85CSV8GRS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw3LElV_7sFK1ZsIpHvwDvebLWUin8n_8',
    appId: '1:1065966968008:android:5bad27f169dfc20a83d9fd',
    messagingSenderId: '1065966968008',
    projectId: 'chatapp-54837',
    storageBucket: 'chatapp-54837.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOqw5T-dwdYmI4fjIj-_c7CqP1aRRuk0k',
    appId: '1:1065966968008:ios:2bc5895f978502b983d9fd',
    messagingSenderId: '1065966968008',
    projectId: 'chatapp-54837',
    storageBucket: 'chatapp-54837.appspot.com',
    androidClientId: '1065966968008-a4ug3plor0mjgmsvo9jdmqp8lqdij50o.apps.googleusercontent.com',
    iosClientId: '1065966968008-h07kg8db6spmpb7h2qn73n3rdfe06opk.apps.googleusercontent.com',
    iosBundleId: 'com.example.chat',
  );
}
