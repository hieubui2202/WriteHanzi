import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/services/auth_service.dart';
import '../../features/auth/services/progress_service.dart';
import '../../models/hanzi_character.dart';
import '../../models/user_profile.dart';
import '../../repositories/character_repository.dart';

class LessonStep {
  const LessonStep({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const List<LessonStep> defaultLessonSteps = [
  LessonStep(
    title: 'Nghe phát âm',
    description: 'Chọn cách đọc chuẩn cho ký tự này.',
    icon: Icons.hearing,
  ),
  LessonStep(
    title: 'Hiểu nghĩa',
    description: 'Liên kết ký tự với nghĩa tiếng Việt.',
    icon: Icons.translate,
  ),
  LessonStep(
    title: 'Theo nét mẫu',
    description: 'Lần theo nét chuẩn trước khi tự viết.',
    icon: Icons.gesture,
  ),
  LessonStep(
    title: 'Ghép bộ thủ',
    description: 'Nhớ lại các thành phần tạo nên ký tự.',
    icon: Icons.extension,
  ),
  LessonStep(
    title: 'Tự luyện viết',
    description: 'Viết lại ký tự để hoàn tất bài học.',
    icon: Icons.brush,
  ),
];

class CharacterLessonScreen extends StatelessWidget {
  CharacterLessonScreen({
    super.key,
    required this.unitId,
    required this.characterId,
    this.initialCharacter,
  });

  final String unitId;
  final String characterId;
  final HanziCharacter? initialCharacter;
  final CharacterRepository _characterRepository = CharacterRepository();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    final progressService = Provider.of<ProgressService>(context, listen: false);

    return StreamBuilder<HanziCharacter?>(
      stream: _characterRepository.getCharacterStream(characterId),
      initialData: initialCharacter,
      builder: (context, characterSnapshot) {
        final character = characterSnapshot.data ?? initialCharacter;

        if (character == null) {
          if (characterSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy dữ liệu ký tự.')),
          );
        }

        final progressKey = character.id.isNotEmpty ? character.id : character.hanzi;

        return StreamBuilder<UserProfile?>(
          stream: user != null
              ? progressService.getUserProfileStream(user.uid)
              : Stream.value(null),
          builder: (context, profileSnapshot) {
            final userProfile = profileSnapshot.data;
            final completed = userProfile?.progress[progressKey] == 'completed';

            return Scaffold(
              appBar: AppBar(
                title: Text('Bài học ${character.hanzi}'),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                  children: [
                    _LessonHero(character: character, completed: completed),
                    const SizedBox(height: 24),
                    _CharacterQuickFacts(character: character),
                    const SizedBox(height: 32),
                    Text(
                      'Các bước luyện giống Duolingo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...defaultLessonSteps.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: _LessonStepCard(
                          stepNumber: entry.key + 1,
                          step: entry.value,
                          completed: completed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      completed
                          ? 'Bạn đã hoàn thành ký tự này. Ôn lại để giữ chuỗi luyện tập!'
                          : 'Hoàn thành từng bước để nhận XP và tăng streak.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: ElevatedButton.icon(
                  icon: Icon(completed ? Icons.refresh : Icons.play_arrow),
                  label: Text(completed ? 'Ôn lại luyện viết' : 'Bắt đầu luyện viết'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () {
                    context.push(
                      '/unit/$unitId/lesson/${character.id.isNotEmpty ? character.id : character.hanzi}/write',
                      extra: character,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LessonHero extends StatelessWidget {
  const _LessonHero({required this.character, required this.completed});

  final HanziCharacter character;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    character.hanzi,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.pinyin,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.meaning,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: completed
                            ? Colors.green.withOpacity(0.15)
                            : colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            completed ? Icons.check_circle : Icons.bolt,
                            color: completed ? Colors.green : colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            completed ? 'Đã hoàn thành' : 'Sẵn sàng luyện tập',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: completed ? Colors.green : colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (character.word != null && character.word!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Từ ví dụ',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              character.word!,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}

class _CharacterQuickFacts extends StatelessWidget {
  const _CharacterQuickFacts({required this.character});

  final HanziCharacter character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _FactChip(
          icon: Icons.draw,
          label: '${character.strokeCount ?? character.strokePaths.length} nét',
        ),
        if (character.section != null && character.section!.isNotEmpty)
          _FactChip(
            icon: Icons.map,
            label: character.section!,
          ),
        if (character.ttsUrl != null && character.ttsUrl!.isNotEmpty)
          _FactChip(
            icon: Icons.volume_up,
            label: 'Có âm thanh',
          ),
        if (character.strokePaths.isNotEmpty)
          _FactChip(
            icon: Icons.timeline,
            label: 'Có hướng dẫn nét',
          ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LessonStepCard extends StatelessWidget {
  const _LessonStepCard({
    required this.stepNumber,
    required this.step,
    required this.completed,
  });

  final int stepNumber;
  final LessonStep step;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withOpacity(0.12)
            : colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed ? Colors.green : colorScheme.surfaceVariant,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: completed
                ? Colors.green
                : colorScheme.primary.withOpacity(0.15),
            foregroundColor:
                completed ? Colors.white : colorScheme.primary,
            child: Text(stepNumber.toString()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            completed ? Icons.check_circle : Icons.lock_open,
            color: completed ? Colors.green : colorScheme.outline,
          ),
        ],
      ),
    );
  }
}
