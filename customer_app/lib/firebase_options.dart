// File generated manually from Firebase project configuration.
// Project: fixawy-app-production
//
// To regenerate, run `flutterfire configure` from the project root.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the Fixawy Customer app.
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
        return android; // fallback for desktop dev
      case TargetPlatform.linux:
        return android; // fallback for desktop dev
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android (com.fixawy.customer) ──────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWCIDLOLoQZQOtEOv7n3JBCi41_Hr7WWk',
    appId: '1:616835894792:android:aa77416e8eec7caa984bbd',
    messagingSenderId: '616835894792',
    projectId: 'fixawy-app-production',
    storageBucket: 'fixawy-app-production.firebasestorage.app',
  );

  // ── Web ────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB9tLUEKkCYwXiuN17MfE7EhqqebKxxujY',
    appId: '1:616835894792:web:dac7587ccb20bb19984bbd',
    messagingSenderId: '616835894792',
    projectId: 'fixawy-app-production',
    authDomain: 'fixawy-app-production.firebaseapp.com',
    storageBucket: 'fixawy-app-production.firebasestorage.app',
  );

  // ── iOS (placeholder — register an iOS app in Firebase Console) ────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWCIDLOLoQZQOtEOv7n3JBCi41_Hr7WWk',
    appId: '1:616835894792:android:aa77416e8eec7caa984bbd', // TODO: replace with iOS app ID
    messagingSenderId: '616835894792',
    projectId: 'fixawy-app-production',
    storageBucket: 'fixawy-app-production.firebasestorage.app',
    iosBundleId: 'com.fixawy.customer', // TODO: confirm bundle ID
  );

  // ── macOS (placeholder) ────────────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWCIDLOLoQZQOtEOv7n3JBCi41_Hr7WWk',
    appId: '1:616835894792:android:aa77416e8eec7caa984bbd', // TODO: replace with macOS app ID
    messagingSenderId: '616835894792',
    projectId: 'fixawy-app-production',
    storageBucket: 'fixawy-app-production.firebasestorage.app',
    iosBundleId: 'com.fixawy.customer', // TODO: confirm bundle ID
  );
}
