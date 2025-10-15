
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'src/features/lesson_flow/character_lesson_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run seeding in the background, don't block UI
  _seedData();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'HanziMaster',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'unit/:unitId',
          builder: (BuildContext context, GoRouterState state) {
            final String unitId = state.pathParameters['unitId']!;
            return UnitScreen(unitId: unitId);
          },
        ),
      ],
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HanziMaster'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('units').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final units = snapshot.data!.docs;
          return ListView.builder(
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              // Safely access data
              final data = unit.data() as Map<String, dynamic>? ?? {};
              final unitName = data['unitName'] as String? ?? 'Unnamed Unit';
              final unitId = unit.id;
              
              return ListTile(
                title: Text(unitName, style: Theme.of(context).textTheme.titleLarge),
                onTap: () => context.go('/unit/$unitId'),
              );
            },
          );
        },
      ),
    );
  }
}

class UnitScreen extends StatelessWidget {
  final String unitId;
  const UnitScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unit: $unitId')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('units').doc(unitId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("Unit not found."));

          final unitData = snapshot.data!.data() as Map<String, dynamic>;
          final characterIds = List<String>.from(unitData['characters'] ?? []);

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0, childAspectRatio: 1.0),
            itemCount: characterIds.length,
            itemBuilder: (context, index) {
              final charId = characterIds[index];
              return CharacterCard(characterId: charId);
            },
          );
        },
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final String characterId;
  const CharacterCard({super.key, required this.characterId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('characters').doc(characterId).get(),
      builder: (context, snapshot) {
        // CORRECT, ROBUST CHECKING
        if (snapshot.hasError) return const Card(child: Center(child: Icon(Icons.error)));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Card(child: Center(child: Text('?')));
        }
        
        // This is now safe
        final characterData = snapshot.data!.data() as Map<String, dynamic>;
        final meaning = characterData['meaning'] as String? ?? '';

        return Card(
          elevation: 4.0,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CharacterLessonScreen(characterId: characterId),
                ),
              );
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(characterId, style: Theme.of(context).textTheme.displayLarge),
                  Text(meaning, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
