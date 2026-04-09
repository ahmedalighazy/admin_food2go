import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for different platforms
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError('Platform not supported');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyC2wem9KvYp-Wm7pgpYgkT4HjBi0aHAd3w",
    appId: "1:191292342718:android:383cd678217426a6aef9ef",
    messagingSenderId: "191292342718",
    projectId: "food2go-8676e",
    storageBucket: "food2go-8676e.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "YOUR_IOS_APP_ID",
    messagingSenderId: "191292342718",
    projectId: "food2go-8676e",
    storageBucket: "food2go-8676e.firebasestorage.app",
    iosBundleId: "com.example.adminFood2go",
  );
}
