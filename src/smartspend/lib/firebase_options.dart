import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDRi-XiFHdMZUUYQi0zzJc11hSdvkz8f_4',
    appId: '1:246602751972:android:3eaf9606eeb16670b431f1',
    messagingSenderId: '246602751972',
    projectId: 'smartspend-f94b7',
    storageBucket: 'smartspend-f94b7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRi-XiFHdMZUUYQi0zzJc11hSdvkz8f_4',
    appId: '1:246602751972:ios:DEINE_IOS_APP_ID',  // Musst du später hinzufügen
    messagingSenderId: '246602751972',
    projectId: 'smartspend-f94b7',
    storageBucket: 'smartspend-f94b7.firebasestorage.app',
    iosBundleId: 'com.example.hciApp',
  );
}