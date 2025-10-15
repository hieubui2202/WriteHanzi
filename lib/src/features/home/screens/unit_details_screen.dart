
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/features/auth/services/progress_service.dart';
import 'package:myapp/src/features/practice/practice_payload.dart';
import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';
import 'package:myapp/src/models/user_profile.dart';
import 'package:myapp/src/repositories/character_repository.dart';

class UnitDetailsScreen extends StatelessWidget {
  final Unit unit;

  const UnitDetailsScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.secondaryContainer.withOpacity(0.5),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<HanziCharacter>>(
            stream: CharacterRepository().getCharactersForUnit(
              unit.id,
              unit: unit,
              sectionTitle: unit.title,
              fallbackIds: unit.characters,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có ký tự nào trong bài này.'));
              }

              final characters = snapshot.data!;

              return StreamBuilder<UserProfile?>(
                stream: user != null ? ProgressService().getUserProfileStream(user.uid) : Stream.value(null),
                builder: (context, userProfileSnapshot) {
                  final userProfile = userProfileSnapshot.data;
                  final completedCount = characters
                      .where((character) => _isCharacterCompleted(
                            profile: userProfile,
                            unitId: unit.id,
                            characterId: character.id,
                          ))
                      .length;

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: _UnitHeader(
                            unit: unit,
                            completed: completedCount,
                            total: characters.length,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        sliver: SliverList.separated(
                          itemCount: characters.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final character = characters[index];
                            final isCompleted = _isCharacterCompleted(
                              profile: userProfile,
                              unitId: unit.id,
                              characterId: character.id,
                            );

                            return _CharacterTile(
                              character: character,
                              isCompleted: isCompleted,
                              onTap: () => context.go(
                                '/unit/${unit.id}/practice/${character.id}',
                                extra: PracticePayload(unit: unit, character: character),
                              ),
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
      ),
    );
  }
}

Map<String, dynamic> _progressForUnit(UserProfile? profile, String unitId) {
  if (profile == null) {
    return const {};
  }

  final raw = profile.progress[unitId];
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

bool _isProgressEntryCompleted(dynamic entry) {
  if (entry == null) {
    return false;
  }
  if (entry is bool) {
    return entry;
  }
  if (entry is num) {
    return entry > 0;
  }
  if (entry is String) {
    final value = entry.toLowerCase();
    return value == 'completed' || value == 'true' || value == 'done';
  }
  if (entry is Map) {
    return _isProgressEntryCompleted(entry['completed']);
  }
  return false;
}

bool _isCharacterCompleted({
  required UserProfile? profile,
  required String unitId,
  required String characterId,
}) {
  if (profile == null) {
    return false;
  }

  final unitProgress = _progressForUnit(profile, unitId);
  if (_isProgressEntryCompleted(unitProgress[characterId])) {
    return true;
  }

  return _isProgressEntryCompleted(profile.progress[characterId]);
}

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({
    required this.unit,
    required this.completed,
    required this.total,
  });

  final Unit unit;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unit.title,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            unit.description,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 26),
              const SizedBox(width: 8),
              Text(
                '$total ký tự',
                style: textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surface.withOpacity(0.4),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            '$completed / $total đã hoàn thành',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CharacterTile extends StatelessWidget {
  const _CharacterTile({
    required this.character,
    required this.isCompleted,
    required this.onTap,
  });

  final HanziCharacter character;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                character.hanzi,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.pinyin,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    character.meaning,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isCompleted ? colorScheme.primary : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.edit,
                    size: 18,
                    color: isCompleted ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCompleted ? 'Đã xong' : 'Luyện',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                          color:
                              isCompleted ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
