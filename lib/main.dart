
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/app/core/app_theme.dart';
import 'package:myapp/app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp is the new root widget for the application.
    // It provides routing, dependency management, and more.
    return GetMaterialApp(
      title: 'Hanzì Journey',
      theme: AppTheme.lightTheme,
      // Define the initial route and the list of all pages.
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // Disable the default debug banner.
      debugShowCheckedModeBanner: false,
    );
  }
}

