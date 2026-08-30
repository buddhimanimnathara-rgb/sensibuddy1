import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

import 'core/router/app_router.dart';
import 'core/services/language_service.dart';
import 'core/services/face_recognition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // LOAD ENV
  // ==========================================================

  await dotenv.load(
    fileName: ".env",
  );

  // ==========================================================
  // INITIALIZE FIREBASE
  // ==========================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==========================================================
  // FIREBASE APP CHECK
  // DEBUG MODE - DEVELOPMENT ONLY
  // ==========================================================

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // ==========================================================
  // LOAD FACE RECOGNITION MODEL
  // ==========================================================

  await faceRecognitionService.loadModel();

  faceRecognitionService.printModelInfo();

  // ==========================================================
  // START APP
  // ==========================================================

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const SensiBuddyApp(),
    ),
  );
}

class SensiBuddyApp extends StatelessWidget {
  const SensiBuddyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SensiBuddy",

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),

      initialRoute: "/",

      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}