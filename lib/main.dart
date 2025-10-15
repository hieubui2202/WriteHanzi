
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

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
      displayLarge: GoogleFonts.notoSans(fontSize: 57, fontWeight: FontWeight.bold),
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
        titleTextStyle: GoogleFonts.notoSans(fontSize: 24, fontWeight: FontWeight.bold),
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
              final data = unit.data() as Map<String, dynamic>? ?? const <String, dynamic>{};

              final unitName = (data['title'] ??
                      data['name'] ??
                      data['unitName'] ??
                      data['sectionTitle'] ??
                      unit.id)
                  .toString();

              return ListTile(
                title: Text(
                  unitName.isEmpty ? unit.id : unitName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: _buildUnitSubtitle(context, data),
                onTap: () => context.go('/unit/${unit.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

Widget? _buildUnitSubtitle(BuildContext context, Map<String, dynamic> data) {
  final description = (data['description'] ?? data['sectionDescription'] ?? '').toString();
  if (description.isEmpty) {
    final orderValue = data['order'] ?? data['index'];
    final orderText = orderValue == null ? null : orderValue.toString();
    return orderText == null
        ? null
        : Text('Order: $orderText', style: Theme.of(context).textTheme.bodySmall);
  }
  return Text(description, style: Theme.of(context).textTheme.bodyMedium);
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
          final charactersField = unitData['characters'] ?? unitData['characterIds'] ?? unitData['words'];
          final characterIds = <String>[];
          if (charactersField is List) {
            for (final entry in charactersField) {
              if (entry == null) continue;
              final value = entry.toString().trim();
              if (value.isNotEmpty) {
                characterIds.add(value);
              }
            }
          } else if (charactersField is String && charactersField.isNotEmpty) {
            characterIds.addAll(
              charactersField
                  .split(',')
                  .map((value) => value.trim())
                  .where((value) => value.isNotEmpty),
            );
          }

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
        final hanzi = (characterData['hanzi'] ?? characterData['character'] ?? characterId).toString();
        final pinyin = (characterData['pinyin'] ?? characterData['transliteration'] ?? '').toString();
        final meaning = (characterData['meaning'] ?? characterData['translation'] ?? '').toString();

        return Card(
          elevation: 4.0,
          child: InkWell(
            onTap: () { /* Handle card tap */ },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(hanzi, style: Theme.of(context).textTheme.displayLarge),
                  if (pinyin.isNotEmpty)
                    Text(pinyin, style: Theme.of(context).textTheme.bodyMedium),
                  if (meaning.isNotEmpty)
                    Text(
                      meaning,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
