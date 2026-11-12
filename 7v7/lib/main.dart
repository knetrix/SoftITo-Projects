import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'firebase_options.dart';

/// `--dart-define=USE_EMULATORS=true` ile Firebase Emulator Suite kullanılır.
const _useEmulators = bool.fromEnvironment('USE_EMULATORS');

/// Emülatör adresi; Android emülatöründe `10.0.2.2`.
const _emulatorHost = String.fromEnvironment('EMULATOR_HOST');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_useEmulators) {
    final host = _emulatorHost.isNotEmpty
        ? _emulatorHost
        : (defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1');
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const SevenApp(),
    ),
  );
}
