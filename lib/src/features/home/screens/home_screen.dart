
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/auth/services/progress_service.dart';
import 'package:myapp/src/features/home/widgets/user_profile_header.dart';
import 'package:myapp/src/models/unit.dart';
import 'package:myapp/src/models/user_profile.dart';
import 'package:myapp/src/repositories/unit_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.12),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lộ trình học',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đăng xuất',
                      onPressed: () => authService.signOut(),
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
              ),
              const UserProfileHeader(),
              Expanded(
                child: StreamBuilder<List<Unit>>(
                  stream: UnitRepository().getUnits(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không tìm thấy bài học nào.'));
                    }

                    final units = snapshot.data!;

                    return StreamBuilder<UserProfile?>(
                      stream: authService.user != null
                          ? ProgressService().getUserProfileStream(authService.user!.uid)
                          : Stream.value(null),
                      builder: (context, profileSnapshot) {
                        final profile = profileSnapshot.data;
                        return CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              sliver: SliverList.separated(
                                itemCount: units.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final unit = units[index];
                                  final completion = _calculateProgress(unit, profile);

                                  return _UnitCard(
                                    unit: unit,
                                    progress: completion,
                                    onTap: () => context.go('/unit/${unit.id}', extra: unit),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _UnitProgress _calculateProgress(Unit unit, UserProfile? profile) {
    if (profile == null) {
      return _UnitProgress(total: unit.characters.length, completed: 0);
    }

    final completed = unit.characters
        .where((characterId) => profile.progress[characterId] == 'completed')
        .length;

    return _UnitProgress(total: unit.characters.length, completed: completed);
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.progress,
    required this.onTap,
  });

  final Unit unit;
  final _UnitProgress progress;
  final VoidCallback onTap;

  Color _statusColor(ColorScheme scheme) {
    if (progress.completed == 0) {
      return scheme.outlineVariant;
    }
    if (progress.completed == progress.total) {
      return scheme.primary;
    }
    return Colors.amber.shade600;
  }

  String get _statusLabel {
    if (progress.total == 0) {
      return 'Đang cập nhật';
    }
    if (progress.completed == 0) {
      return 'Chưa học';
    }
    if (progress.completed == progress.total) {
      return 'Hoàn thành';
    }
    return 'Đang học';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme);
    final completionRatio = progress.total == 0
        ? 0
        : progress.completed / progress.total;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.8),
              colorScheme.primaryContainer.withOpacity(0.35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          unit.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          progress.completed == progress.total
                              ? Icons.check_circle
                              : Icons.auto_awesome,
                          color: statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: completionRatio,
                  minHeight: 6,
                  backgroundColor: colorScheme.surface.withOpacity(0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress.completed}/${progress.total} ký tự',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Row(
                    children: const [
                      Text('Bắt đầu', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitProgress {
  const _UnitProgress({required this.total, required this.completed});

  final int total;
  final int completed;
}
