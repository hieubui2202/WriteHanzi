
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/admin/screens/admin_screen.dart';
import 'package:myapp/src/features/auth/screens/login_screen.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/home/screens/home_screen.dart';
import 'package:myapp/src/features/home/screens/unit_details_screen.dart';
import 'package:myapp/src/features/lesson_flow/character_lesson_screen.dart';
import 'package:myapp/src/features/writing/screens/writing_screen_loader.dart';
import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';

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
                  final unitId = state.pathParameters['unitId'];
                  if (unitId == null) {
                    return const Scaffold(
                      body: Center(child: Text('Lỗi: không tìm thấy bài học')),
                    );
                  }

                  final extra = state.extra;
                  final Unit? initialUnit = extra is Unit ? extra : null;

                  return UnitDetailsScreen(
                    unitId: unitId,
                    initialUnit: initialUnit,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'lesson/:characterId',
                    builder: (context, state) {
                      final unitId = state.pathParameters['unitId'];
                      final characterId = state.pathParameters['characterId'];
                      if (unitId == null || characterId == null) {
                        return const Scaffold(
                          body: Center(child: Text('Lỗi: không tìm thấy ký tự.')),
                        );
                      }

                      final extra = state.extra;
                      final HanziCharacter? initialCharacter =
                          extra is HanziCharacter ? extra : null;

                      return CharacterLessonScreen(
                        unitId: unitId,
                        characterId: characterId,
                        initialCharacter: initialCharacter,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'write',
                        builder: (context, state) {
                          final characterId = state.pathParameters['characterId'];
                          if (characterId == null) {
                            return const Scaffold(
                              body: Center(child: Text('Lỗi: không tìm thấy ký tự.')),
                            );
                          }

                          final extra = state.extra;
                          final HanziCharacter? initialCharacter =
                              extra is HanziCharacter ? extra : null;

                          return WritingScreenLoader(
                            characterId: characterId,
                            initialCharacter: initialCharacter,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'write/:characterId',
                    builder: (context, state) {
                      final characterId = state.pathParameters['characterId'];
                      if (characterId == null) {
                        return const Scaffold(
                          body: Center(child: Text('Lỗi: không tìm thấy ký tự.')),
                        );
                      }

                      final extra = state.extra;
                      final HanziCharacter? initialCharacter =
                          extra is HanziCharacter ? extra : null;

                      return WritingScreenLoader(
                        characterId: characterId,
                        initialCharacter: initialCharacter,
                      );
                    },
                  ),
                ],
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
