
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/admin/screens/admin_screen.dart';
import 'package:myapp/src/features/auth/screens/login_screen.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/home/screens/home_screen.dart';
import 'package:myapp/src/features/home/screens/unit_details_screen.dart';
import 'package:myapp/src/data/fallback_content.dart';
import 'package:myapp/src/features/practice/practice_flow_screen.dart';
import 'package:myapp/src/features/practice/practice_payload.dart';
import 'package:myapp/src/models/unit.dart';

class AppRouter {
  AppRouter(this.authService);

  final AuthService authService;

  late final GoRouter router = GoRouter(
    initialLocation: authService.user == null ? '/login' : '/',
    refreshListenable: authService,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'unit/:unitId',
            builder: (context, state) {
              final unit = state.extra;
              if (unit is Unit) {
                return UnitDetailsScreen(unit: unit);
              }
              final unitId = state.pathParameters['unitId'];
              final fallbackUnits = FallbackContent.units;
              if (fallbackUnits.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('Lỗi: không tìm thấy bài học')), 
                );
              }
              final fallbackUnit = fallbackUnits.firstWhere(
                (item) => item.id == unitId,
                orElse: () => fallbackUnits.first,
              );
              return UnitDetailsScreen(unit: fallbackUnit);
            },
            routes: [
              GoRoute(
                path: 'practice/:characterId',
                builder: (context, state) {
                  final extra = state.extra;
                  if (extra is PracticePayload) {
                    return PracticeFlowScreen(payload: extra);
                  }

                  final unitId = state.pathParameters['unitId'];
                  final characterId = state.pathParameters['characterId'] ?? '';
                  final fallbackUnits = FallbackContent.units;
                  if (fallbackUnits.isEmpty) {
                    return const Scaffold(
                      body: Center(child: Text('Lỗi: không tìm thấy ký tự')),
                    );
                  }
                  final unit = fallbackUnits.firstWhere(
                    (item) => item.id == unitId,
                    orElse: () => fallbackUnits.first,
                  );
                  final character = FallbackContent.characterById(characterId);

                  if (character != null) {
                    return PracticeFlowScreen(
                      payload: PracticePayload(unit: unit, character: character),
                    );
                  }

                  return const Scaffold(
                    body: Center(child: Text('Lỗi: không tìm thấy ký tự')), 
                  );
                },
              ),
            ],
          ),
        ],
      ),
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
