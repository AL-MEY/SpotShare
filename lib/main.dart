import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/app.dart';
import 'package:spotshare/i18n/strings.g.dart';

Future<void> runMainApp(FirebaseOptions firebaseOptions) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  await LocaleSettings.useDeviceLocale();
  runApp(
    ProviderScope(child: TranslationProvider(child: const SpotShareApp())),
  );
}
