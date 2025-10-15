import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'src/core/theme/theme_provider.dart';
import 'src/features/auth/services/auth_service.dart';
import 'src/features/auth/services/progress_service.dart';
import 'src/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HanziApp());
}

class HanziApp extends StatelessWidget {
  const HanziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ProgressService()),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = AppRouter(context);
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              const Color primarySeedColor = Colors.blueAccent;
              final TextTheme appTextTheme = TextTheme(
                displayLarge: GoogleFonts.notoSans(
                  fontSize: 57,
                  fontWeight: FontWeight.bold,
                ),
                titleLarge: GoogleFonts.notoSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                bodyMedium: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              );

              final ThemeData lightTheme = ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: primarySeedColor,
                  brightness: Brightness.light,
                ),
                textTheme: appTextTheme,
                appBarTheme: AppBarTheme(
                  backgroundColor: primarySeedColor,
                  foregroundColor: Colors.white,
                  titleTextStyle: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primarySeedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );

              final ThemeData darkTheme = ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: primarySeedColor,
                  brightness: Brightness.dark,
                ),
                textTheme: appTextTheme,
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.grey.shade900,
                  foregroundColor: Colors.white,
                  titleTextStyle: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: primarySeedColor.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );

              return MaterialApp.router(
                title: 'Hanzi Writing Trainer',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
