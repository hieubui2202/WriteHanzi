
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'package:myapp/src/core/routing/app_router.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/auth/services/progress_service.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ProgressService()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _seedData() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final charactersSnapshot = await firestore.collection('characters').limit(1).get();
    if (charactersSnapshot.docs.isEmpty) {
      print("Seeding data...");
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
          userData['lastLogin'] = Timestamp.fromDate(DateTime.parse(userData['lastLogin']));
        }
        batch.set(docRef, userData);
      });

      await batch.commit();
      print("Data seeding complete.");
    } else {
      print("Data already exists. Skipping seeding.");
    }
  } catch (e) {
    print("Error seeding data: $e");
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authService = context.read<AuthService>();
    _router = AppRouter(authService).router;
  }

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.teal;
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.notoSansSc(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.notoSansSc(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.dark),
      textTheme: appTextTheme,
    );

    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'HanziMaster',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
