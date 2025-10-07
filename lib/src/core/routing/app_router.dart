
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/admin/screens/admin_screen.dart';
import 'package:myapp/src/features/auth/screens/login_screen.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/home/screens/home_screen.dart';
import 'package:myapp/src/features/home/screens/unit_details_screen.dart';
import 'package:myapp/src/features/writing/screens/writing_screen.dart';
import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';
import 'package:myapp/src/repositories/fallback_content.dart';

class AppRouter {
  AppRouter(this.authService);

  final AuthService authService;

  GoRouter get router => GoRouter(
        initialLocation: '/login',
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
                      } else {
                        final unitId = state.pathParameters['unitId'];
                        if (unitId != null) {
                          try {
                            unit = FallbackContent.units
                                .firstWhere((fallbackUnit) => fallbackUnit.id == unitId);
                          } catch (_) {}
                        }
                      }

                      if (unit != null) {
                        return UnitDetailsScreen(unit: unit);
                      }
                      return const Scaffold(body: Center(child: Text('Lỗi: không tìm thấy bài học')));
                    },
                    routes: [
                      GoRoute(
                        path: 'write/:characterId',
                        builder: (context, state) {
                          final extra = state.extra;
                          HanziCharacter? character;
                          if (extra is HanziCharacter) {
                            character = extra;
                          } else if (extra is Map<String, dynamic> &&
                              extra['character'] is HanziCharacter) {
                            character = extra['character'] as HanziCharacter;
                          }

                          if (character == null) {
                            final characterId = state.pathParameters['characterId'];
                            if (characterId != null) {
                              try {
                                character = FallbackContent.characters.firstWhere(
                                  (fallbackCharacter) => fallbackCharacter.id == characterId,
                                );
                              } catch (_) {}
                            }
                          }
                          if (character != null) {
                            return WritingScreen(character: character);
                          }
                          return const Scaffold(body: Center(child: Text('Lỗi: không tìm thấy ký tự')));
                        },
                      )
                    ]),
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
