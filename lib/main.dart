import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/firebase_options.dart'; // Import this

import 'app/routes/app_pages.dart';

// Modify the main function to be async
void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    return GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primarySeedColor,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primarySeedColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
