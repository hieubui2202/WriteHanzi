
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/admin/screens/admin_screen.dart';
import 'package:myapp/src/features/auth/screens/login_screen.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/home/screens/home_screen.dart';
import 'package:myapp/src/features/home/screens/unit_details_screen.dart';
import 'package:myapp/src/features/writing/screens/writing_screen.dart';
import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';
import 'package:myapp/src/features/writing_practice/writing_practice_screen.dart';

class AppRouter {
  final BuildContext context;

  AppRouter(this.context);

  GoRouter get router {
    final authService = Provider.of<AuthService>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      refreshListenable: authService,
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                  path: 'unit/:unitId',
                  builder: (context, state) {
                    final extra = state.extra;
                    Unit? unit;
                    if (extra is Unit) {
                      unit = extra;
                    } else if (extra is Map<String, dynamic> && extra['unit'] is Unit) {
                      unit = extra['unit'] as Unit;
                    }

                    if (unit != null) {
                      return UnitDetailsScreen(unit: unit);
                    }

                    return const Scaffold(
                      body: Center(child: Text('Lỗi: không tìm thấy bài học')),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'write/:characterId',
                      builder: (context, state) {
                        final extra = state.extra;
                        HanziCharacter? character;
                        if (extra is HanziCharacter) {
                          character = extra;
                        } else if (extra is Map<String, dynamic> && extra['character'] is HanziCharacter) {
                          character = extra['character'] as HanziCharacter;
                        }

                        if (character != null) {
                          return WritingScreen(character: character);
                        }

                        return const Scaffold(
                          body: Center(child: Text('Lỗi: không tìm thấy ký tự')),
                        );
                      },
                    )
                  ]),
               GoRoute(
                path: 'practice',
                builder: (context, state) => const WritingPracticeScreen(),
              ),
            ]),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authService.user != null;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        if (isLoggedIn && isLoggingIn) {
          return '/';
        }

        return null;
      },
    );
  }
}
