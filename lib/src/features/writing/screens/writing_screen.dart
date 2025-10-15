
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hanzi_character.dart';
import '../../../features/auth/services/progress_service.dart';
import '../providers/drawing_provider.dart';
import '../widgets/writing_pad.dart';

class WritingScreen extends StatelessWidget {
  final HanziCharacter character;

  const WritingScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(strokeData: character.strokeData),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Luyện viết'),
        ),
        body: Column(
          children: [
            _LessonHeader(character: character),
            const SizedBox(height: 12),
            _ProgressBanner(total: character.strokeData.paths.length),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const ColoredBox(
                        color: Colors.transparent,
                        child: WritingPad(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _StrokeControls(),
            const SizedBox(height: 12),
            _buildCompletionButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context) {
    final progressService = Provider.of<ProgressService>(context, listen: false);

    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Hoàn thành bài luyện'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: drawingProvider.isComplete
                ? () async {
                    await progressService.completeCharacter(character.progressKey, 10);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tiến độ đã được lưu!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.character});

  final HanziCharacter character;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            character.hanzi,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 72,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            character.pinyin,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            character.meaning,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, _) {
        final completed = drawingProvider.strokeProgress
            .where((value) => value >= 1)
            .length
            .clamp(0, total);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ nét',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '$completed / $total',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: drawingProvider.completionRatio,
                  minHeight: 8,
                  color: const Color(0xFF00CFFF),
                  backgroundColor: Colors.white10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StrokeControls extends StatelessWidget {
  const _StrokeControls();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.undo),
                label: const Text('Hoàn tác'),
                onPressed: drawingProvider.canUndo ? drawingProvider.undo : null,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xóa nét'),
                onPressed:
                    drawingProvider.canClear ? drawingProvider.clear : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
