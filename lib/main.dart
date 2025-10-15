import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/core/routing/app_router.dart';
import 'src/features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run seeding in the background, don't block UI
  _seedData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<GoRouter>(
          create: (context) => AppRouter(context).router,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _seedData() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final charactersSnapshot =
        await firestore.collection('characters').limit(1).get();
    if (charactersSnapshot.docs.isEmpty) {
      debugPrint('Seeding data...');
      final String jsonString = await rootBundle.loadString('assets/seed.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final WriteBatch batch = firestore.batch();

      // Seed Characters
      final Map<String, dynamic> characters = data['characters'] ?? {};
      characters.forEach((key, value) {
        final docRef = firestore.collection('characters').doc(key);
        batch.set(docRef, value);
      });

      // Seed Units
      final Map<String, dynamic> units = data['units'] ?? {};
      units.forEach((key, value) {
        final docRef = firestore.collection('units').doc(key);
        batch.set(docRef, value);
      });

      // Seed Users
      final Map<String, dynamic> users = data['users'] ?? {};
      users.forEach((key, value) {
        final docRef = firestore.collection('users').doc(key);
        final Map<String, dynamic> userData = Map<String, dynamic>.from(value);
        if (userData.containsKey('lastLogin')) {
          userData['lastLogin'] =
              Timestamp.fromDate(DateTime.parse(userData['lastLogin']));
        }
        batch.set(docRef, userData);
      });

      await batch.commit();
      debugPrint('Data seeding complete.');
    } else {
      debugPrint('Data already exists. Skipping seeding.');
    }
  } catch (e) {
    debugPrint('Error seeding data: $e');
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.teal;
    final TextTheme appTextTheme = TextTheme(
      displayLarge:
          GoogleFonts.notoSansSc(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.notoSansSc(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.dark),
      textTheme: appTextTheme,
    );

    final themeProvider = Provider.of<ThemeProvider>(context);
    final router = Provider.of<GoRouter>(context, listen: false);

    return MaterialApp.router(
      title: 'HanziMaster',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}
