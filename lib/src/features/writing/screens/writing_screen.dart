
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/auth/services/progress_service.dart';
import 'package:myapp/src/features/writing/providers/drawing_provider.dart';
import 'package:myapp/src/features/writing/widgets/character_overlay.dart';
import 'package:myapp/src/features/writing/widgets/writing_pad.dart';
import 'package:myapp/src/models/hanzi_character.dart';

class WritingScreen extends StatelessWidget {
  final HanziCharacter character;

  const WritingScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Luyện viết'),
          actions: [
            Consumer<DrawingProvider>(
              builder: (context, drawingProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  onPressed: drawingProvider.canUndo ? drawingProvider.undo : null,
                  tooltip: 'Hoàn tác',
                );
              },
            ),
            Consumer<DrawingProvider>(
              builder: (context, drawingProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: drawingProvider.hasStrokes ? drawingProvider.clear : null,
                  tooltip: 'Xóa nét',
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.18),
                colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _CharacterHero(character: character),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.25), width: 2),
                        color: colorScheme.surfaceVariant.withOpacity(0.65),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CharacterOverlay(character: character.hanzi),
                              WritingPad(
                                strokePaths: character.strokeData.paths,
                                viewBox: Size(
                                  character.strokeData.width.toDouble(),
                                  character.strokeData.height.toDouble(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCompletionButton(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context) {
    final progressService = ProgressService();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.celebration_rounded),
          label: const Text('Hoàn thành bài luyện'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            // Award 10 XP for each character completion
            await progressService.completeCharacter(character.id, 10);

            // Show a confirmation dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tiến độ đã được lưu!'),
                backgroundColor: Colors.green,
              ),
            );

            // Pop the screen
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _CharacterHero extends StatelessWidget {
  const _CharacterHero({required this.character});

  final HanziCharacter character;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Row(
        children: [
          Container(
            height: 86,
            width: 86,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              character.hanzi,
              style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.pinyin,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  character.meaning,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '+10 XP khi hoàn thành',
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
