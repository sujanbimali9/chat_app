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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBT6fWPH1QmdtAtDj1RRz9rDYISChkLH54',
    appId: '1:158642611374:android:12c628d5851b5bc82eb93f',
    messagingSenderId: '158642611374',
    projectId: 'chat-f8cfd',
    storageBucket: 'chat-f8cfd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBcRJkgLZRHvhzjLTw7mNHDa_TO6xiYVYw',
    appId: '1:158642611374:ios:cc04243e04e2d8fe2eb93f',
    messagingSenderId: '158642611374',
    projectId: 'chat-f8cfd',
    storageBucket: 'chat-f8cfd.appspot.com',
    androidClientId:
        '158642611374-hknttc54fvc2p23kh6o2hsp5ii6timkq.apps.googleusercontent.com',
    iosClientId:
        '158642611374-do72kgh29upr0l0c6lb5kihh5i1mru71.apps.googleusercontent.com',
    iosBundleId: 'com.example.chat',
  );
}
