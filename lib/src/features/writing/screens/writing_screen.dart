
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/services/progress_service.dart';
import '../../../models/hanzi_character.dart';
import '../logic/stroke_parser.dart';
import '../logic/writing_evaluator.dart';
import '../providers/drawing_provider.dart';
import '../widgets/writing_pad.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({super.key, required this.character});

  final HanziCharacter character;

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen>
    with SingleTickerProviderStateMixin {
  late final List<List<Offset>> _referenceStrokes;
  late final AnimationController _previewController;
  late final Animation<double> _previewAnimation;
  final GlobalKey _boardKey = GlobalKey();

  bool _showOutline = true;
  bool _showStrokeOrder = true;
  bool _xpAwarded = false;
  WritingFeedback? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _referenceStrokes = StrokeParser.parsePaths(widget.character.strokeData);

    final baseDuration = 1600 + (_referenceStrokes.length * 500);
    final durationMs = baseDuration.clamp(1600, 4000).toInt();
    _previewController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    _previewAnimation = CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeInOut,
    );

    if (_showStrokeOrder && _referenceStrokes.isNotEmpty) {
      _previewController.repeat();
    }
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Luyện viết: ${widget.character.hanzi}'),
          actions: [
            Consumer<DrawingProvider>(
              builder: (context, drawingProvider, child) => IconButton(
                icon: const Icon(Icons.undo),
                onPressed: drawingProvider.undo,
                tooltip: 'Hoàn tác',
              ),
            ),
            Consumer<DrawingProvider>(
              builder: (context, drawingProvider, child) => IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: drawingProvider.clear,
                tooltip: 'Xóa toàn bộ',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCoachPanel(context),
              _buildHintChips(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: WritingPad(
                        boardKey: _boardKey,
                        strokeData: widget.character.strokeData,
                        referenceStrokes: _referenceStrokes,
                        showOutline: _showOutline,
                        strokePreview:
                            _showStrokeOrder ? _previewAnimation : null,
                      ),
                    ),
                  ),
                ),
              ),
              if (_lastFeedback != null) _buildFeedbackBanner(context),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Kiểm tra bài viết'),
                  onPressed: () => _evaluateWriting(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoachPanel(BuildContext context) {
    final drawingProvider = context.watch<DrawingProvider>();
    final expectedStrokes = _referenceStrokes.length;
    final completed = drawingProvider.completedStrokeCount;
    final completionRatio = expectedStrokes == 0
        ? 0.0
        : (completed / expectedStrokes).clamp(0.0, 1.0);
    final progressLabel = expectedStrokes == 0
        ? 'Chữ này chưa có dữ liệu nét mẫu, hãy luyện viết tự do.'
        : 'Bạn đã vẽ $completed/$expectedStrokes nét.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.character.hanzi,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.volume_up, size: 18),
                    label: Text(widget.character.pinyin),
                  ),
                  Chip(
                    avatar: const Icon(Icons.lightbulb_outline, size: 18),
                    label: Text(widget.character.meaning),
                  ),
                  Chip(
                    avatar: const Icon(Icons.edit, size: 18),
                    label: Text('${expectedStrokes} nét'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Hãy viết theo thứ tự nét như hướng dẫn của Duolingo: chậm mà chắc, từng nét gọn gàng.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: completionRatio,
                minHeight: 6,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              Text(
                completionRatio == 0 && expectedStrokes > 0
                    ? 'Hãy bắt đầu với nét đầu tiên.'
                    : progressLabel,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilterChip(
            label: Text(_showOutline ? 'Ẩn nét mẫu' : 'Hiện nét mẫu'),
            avatar: Icon(_showOutline ? Icons.visibility_off : Icons.visibility),
            selected: _showOutline,
            onSelected: (value) {
              setState(() {
                _showOutline = value;
              });
            },
          ),
          FilterChip(
            label: const Text('Thứ tự nét'),
            avatar: const Icon(Icons.animation),
            selected: _showStrokeOrder,
            onSelected: (value) {
              setState(() {
                _showStrokeOrder = value;
                if (value) {
                  if (_referenceStrokes.isNotEmpty) {
                    _previewController.repeat();
                  }
                } else {
                  _previewController.stop();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(BuildContext context) {
    final feedback = _lastFeedback!;
    final colorScheme = Theme.of(context).colorScheme;
    final isSuccess = feedback.isSuccess;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: isSuccess
            ? colorScheme.secondaryContainer
            : colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(feedback.score * 100).round()} điểm - ${feedback.headline}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSuccess
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onErrorContainer,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                feedback.detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSuccess
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onErrorContainer,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _evaluateWriting(BuildContext context) async {
    final drawingProvider = context.read<DrawingProvider>();
    if (!drawingProvider.hasInk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hãy viết ký tự trước khi kiểm tra nhé!'),
        ),
      );
      return;
    }

    final renderBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final feedback = WritingEvaluator.evaluate(
      strokeData: widget.character.strokeData,
      referenceStrokes: _referenceStrokes,
      drawnStrokes: drawingProvider.strokes,
      canvasSize: renderBox.size,
    );

    setState(() {
      _lastFeedback = feedback;
    });

    if (!mounted) return;

    if (feedback.isSuccess && !_xpAwarded) {
      await context
          .read<ProgressService>()
          .completeCharacter(widget.character.id, 10);
      _xpAwarded = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã nhận 10 XP cho ký tự này!'),
          ),
        );
      }
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WritingResultSheet(
        character: widget.character,
        feedback: feedback,
        onRetry: () {
          Navigator.of(context).pop();
          this.context.read<DrawingProvider>().clear();
        },
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.of(this.context).maybePop();
        },
      ),
    );
  }
}

class _WritingResultSheet extends StatelessWidget {
  const _WritingResultSheet({
    required this.character,
    required this.feedback,
    required this.onRetry,
    required this.onContinue,
  });

  final HanziCharacter character;
  final WritingFeedback feedback;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                feedback.headline,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Điểm số: ${(feedback.score * 100).toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                character.hanzi,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '${character.pinyin} • ${character.meaning}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _buildStatTile(
                context,
                icon: Icons.draw,
                title: 'Số nét',
                value:
                    '${feedback.drawnStrokes}/${feedback.expectedStrokes} (${(feedback.strokeAccuracy * 100).toStringAsFixed(0)}%)',
              ),
              _buildStatTile(
                context,
                icon: Icons.open_with,
                title: 'Phủ kín ô',
                value:
                    '${(feedback.coverageAccuracy * 100).toStringAsFixed(0)}% phù hợp',
              ),
              _buildStatTile(
                context,
                icon: Icons.straighten,
                title: 'Độ dài nét',
                value:
                    '${(feedback.lengthAccuracy * 100).toStringAsFixed(0)}% tương đồng',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Tiếp tục'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('Thử lại nét viết này'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
