import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/core/routing/app_router.dart';
import 'src/features/auth/services/auth_service.dart';
import 'src/features/auth/services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => ProgressService()),
        Provider<GoRouter>(
          create: (context) => AppRouter(context).router,
        ),
      ],
      child: const MyApp(),
    ),
  );
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
