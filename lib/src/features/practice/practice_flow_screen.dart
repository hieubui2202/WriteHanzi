import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'package:myapp/src/features/auth/services/progress_service.dart';
import 'package:myapp/src/features/practice/practice_payload.dart';
import 'package:myapp/src/features/writing/providers/drawing_provider.dart';
import 'package:myapp/src/features/writing/widgets/character_overlay.dart';
import 'package:myapp/src/features/writing/widgets/writing_pad.dart';
import 'package:myapp/src/models/hanzi_character.dart';

class PracticeFlowScreen extends StatefulWidget {
  const PracticeFlowScreen({super.key, required this.payload});

  final PracticePayload payload;

  @override
  State<PracticeFlowScreen> createState() => _PracticeFlowScreenState();
}

class _PracticeFlowScreenState extends State<PracticeFlowScreen>
    with SingleTickerProviderStateMixin {
  static const _stepTitles = <String>[
    'Giới thiệu',
    'Chọn nghĩa',
    'Xem nét',
    'Tập viết',
    'Nét thiếu',
    'Kết quả',
  ];

  final PageController _pageController = PageController();
  final ProgressService _progressService = ProgressService();

  int _currentStep = 0;
  int _xpEarned = 0;
  bool _meaningPassed = false;
  bool _writingPassed = false;
  bool _missingStrokePassed = false;
  bool _progressRecorded = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    setState(() => _currentStep = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _handleMeaningResult(bool isCorrect) {
    if (!isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đáp án chưa đúng, hãy thử lại nhé!'),
        ),
      );
      return;
    }

    if (!_meaningPassed) {
      _meaningPassed = true;
      _xpEarned += 2;
    }
    _nextStep();
  }

  void _handleWritingComplete() {
    if (!_writingPassed) {
      _writingPassed = true;
      _xpEarned += 6;
    }
    _nextStep();
  }

  Future<void> _handleMissingStrokeComplete() async {
    if (!_missingStrokePassed) {
      _missingStrokePassed = true;
      _xpEarned += 2;
    }

    if (!_progressRecorded) {
      _progressRecorded = true;
      try {
        await _progressService.completeCharacter(
          widget.payload.character.id,
          _xpEarned,
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể lưu tiến độ: $error')),
          );
        }
      }
    }

    if (mounted) {
      _nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.payload.character;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: Column(
          children: [
            _FlowHeader(
              currentStep: _currentStep,
              totalSteps: _stepTitles.length,
              xpEarned: _xpEarned,
              stepTitles: _stepTitles,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _LessonIntroStep(
                    character: character,
                    onNext: _nextStep,
                  ),
                  _MeaningChoiceStep(
                    character: character,
                    onResult: _handleMeaningResult,
                  ),
                  _StrokeDemoStep(
                    character: character,
                    onContinue: _nextStep,
                  ),
                  _WritingPracticeStep(
                    character: character,
                    onSuccess: _handleWritingComplete,
                  ),
                  _MissingStrokeStep(
                    character: character,
                    onSuccess: _handleMissingStrokeComplete,
                  ),
                  _ResultStep(
                    character: character,
                    xpEarned: _xpEarned,
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

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.xpEarned,
    required this.stepTitles,
  });

  final int currentStep;
  final int totalSteps;
  final int xpEarned;
  final List<String> stepTitles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: currentStep / (totalSteps - 1),
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1C2452),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00CFFF)),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2452),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFF78E08F)),
                    const SizedBox(width: 4),
                    Text(
                      '+$xpEarned XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(stepTitles.length, (index) {
                final isActive = index == currentStep;
                final isCompleted = index < currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF00CFFF)
                        : isCompleted
                            ? const Color(0xFF1F2A5C)
                            : const Color(0xFF121C3F),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00CFFF).withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : const [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.circle,
                        size: 16,
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.white54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isActive || isCompleted
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonIntroStep extends StatelessWidget {
  const _LessonIntroStep({required this.character, required this.onNext});

  final HanziCharacter character;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF162451), Color(0xFF10193C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1631),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        character.hanzi,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.pinyin,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            character.meaning,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFC9D4FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF00CFFF),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: character.ttsUrl == null
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Tính năng phát âm sẽ được kích hoạt khi kết nối âm thanh.'),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.volume_up_rounded),
                            label: const Text('Nghe phát âm'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mục tiêu: ghi nhớ nét cơ bản và nghĩa của chữ.',
                  style: TextStyle(color: Color(0xFFC9D4FF)),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              onPressed: onNext,
              child: const Text('Bắt đầu luyện'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MeaningChoiceStep extends StatefulWidget {
  const _MeaningChoiceStep({required this.character, required this.onResult});

  final HanziCharacter character;
  final void Function(bool) onResult;

  @override
  State<_MeaningChoiceStep> createState() => _MeaningChoiceStepState();
}

class _MeaningChoiceStepState extends State<_MeaningChoiceStep> {
  late final List<String> _options;
  String? _selected;

  @override
  void initState() {
    super.initState();
    final distractors = <String>{
      'fire',
      'mountain',
      'wood',
      'person',
      'earth',
    }..remove(widget.character.meaning.toLowerCase());

    final rng = Random();
    final picks = distractors.toList()..shuffle(rng);
    _options = [widget.character.meaning, ...picks.take(2)].toList()..shuffle(rng);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Text(
            'Ý nghĩa của "${widget.character.hanzi}" là gì?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),
          ..._options.map((option) {
            final isSelected = option == _selected;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                tileColor: isSelected ? const Color(0xFF1F2A5C) : const Color(0xFF121C3F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF78E08F))
                    : const Icon(Icons.circle_outlined, color: Colors.white54),
                onTap: () {
                  setState(() => _selected = option);
                  widget.onResult(option == widget.character.meaning);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StrokeDemoStep extends StatefulWidget {
  const _StrokeDemoStep({required this.character, required this.onContinue});

  final HanziCharacter character;
  final VoidCallback onContinue;

  @override
  State<_StrokeDemoStep> createState() => _StrokeDemoStepState();
}

class _StrokeDemoStepState extends State<_StrokeDemoStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<Path> _paths;

  Color _strokeColor = const Color(0xFF00E5FF);
  double _strokeWidth = 4;

  @override
  void initState() {
    super.initState();
    _paths = widget.character.strokeData.paths.map(parseSvgPathData).toList();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: max(1200, _paths.length * 900)),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final strokeData = widget.character.strokeData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1631),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.06),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    Widget buildPalette() => Wrap(
                          spacing: 10,
                          children: [
                            _ColorOption(
                              color: const Color(0xFF00E5FF),
                              selected: _strokeColor == const Color(0xFF00E5FF),
                              onTap: () => setState(() => _strokeColor = const Color(0xFF00E5FF)),
                            ),
                            _ColorOption(
                              color: const Color(0xFFFBBF24),
                              selected: _strokeColor == const Color(0xFFFBBF24),
                              onTap: () => setState(() => _strokeColor = const Color(0xFFFBBF24)),
                            ),
                            _ColorOption(
                              color: const Color(0xFF78E08F),
                              selected: _strokeColor == const Color(0xFF78E08F),
                              onTap: () => setState(() => _strokeColor = const Color(0xFF78E08F)),
                            ),
                            _ColorOption(
                              color: const Color(0xFFFF7AA0),
                              selected: _strokeColor == const Color(0xFFFF7AA0),
                              onTap: () => setState(() => _strokeColor = const Color(0xFFFF7AA0)),
                            ),
                          ],
                        );

                    Widget buildSlider() => Slider(
                          value: _strokeWidth,
                          min: 2,
                          max: 12,
                          divisions: 10,
                          label: _strokeWidth.toStringAsFixed(0),
                          onChanged: (value) => setState(() => _strokeWidth = value),
                        );

                    final replayButton = FilledButton.tonalIcon(
                      onPressed: _replay,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Vẽ lại'),
                    );

                    final isCompact = constraints.maxWidth < 580;
                    if (isCompact) {
                      final sliderWidth = constraints.maxWidth.clamp(180.0, 360.0);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Màu nét:',
                                style: TextStyle(color: Color(0xFFC9D4FF)),
                              ),
                              buildPalette(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Độ dày:',
                                style: TextStyle(color: Color(0xFFC9D4FF)),
                              ),
                              SizedBox(
                                width: sliderWidth,
                                child: buildSlider(),
                              ),
                              replayButton,
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        const Text(
                          'Màu nét:',
                          style: TextStyle(color: Color(0xFFC9D4FF)),
                        ),
                        const SizedBox(width: 12),
                        Flexible(child: buildPalette()),
                        const SizedBox(width: 16),
                        const Text(
                          'Độ dày:',
                          style: TextStyle(color: Color(0xFFC9D4FF)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: buildSlider()),
                        const SizedBox(width: 12),
                        replayButton,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: strokeData.width / strokeData.height,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _StrokeAnimationPainter(
                          progress: _controller.value,
                          originalPaths: _paths,
                          viewBox: Size(
                            strokeData.width.toDouble(),
                            strokeData.height.toDouble(),
                          ),
                          strokeColor: _strokeColor,
                          strokeWidth: _strokeWidth,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              onPressed: widget.onContinue,
              child: const Text('Tôi đã nắm thứ tự nét'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StrokeAnimationPainter extends CustomPainter {
  _StrokeAnimationPainter({
    required this.progress,
    required this.originalPaths,
    required this.viewBox,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final double progress;
  final List<Path> originalPaths;
  final Size viewBox;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF243059)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final dashArray = CircularIntervalList<double>([3, 3]);

    final rectPath = Path()..addRect(rect);
    canvas.drawPath(dashPath(rectPath, dashArray: dashArray), gridPaint);

    final horizontalGuide = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
    canvas.drawPath(dashPath(horizontalGuide, dashArray: dashArray), gridPaint);

    final verticalGuide = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height);
    canvas.drawPath(dashPath(verticalGuide, dashArray: dashArray), gridPaint);

    final progressPerStroke = originalPaths.isEmpty ? 1.0 : 1 / originalPaths.length;
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (var i = 0; i < originalPaths.length; i++) {
      final start = progressPerStroke * i;
      final end = start + progressPerStroke;
      final localProgress = ((progress - start) / progressPerStroke).clamp(0.0, 1.0);

      if (localProgress <= 0) {
        continue;
      }

      final transformedPath = _scalePath(originalPaths[i], size);
      final Path pathToDraw;
      if (localProgress >= 1.0) {
        pathToDraw = transformedPath;
      } else {
        final metrics = transformedPath.computeMetrics();
        final builder = Path();
        for (final metric in metrics) {
          final length = metric.length * localProgress;
          builder.addPath(metric.extractPath(0, length), Offset.zero);
          break;
        }
        pathToDraw = builder;
      }

      canvas.drawPath(pathToDraw, paint);
    }
  }

  Path _scalePath(Path path, Size size) {
    final matrix4 = Matrix4.identity();
    matrix4.scale(
      size.width / viewBox.width,
      size.height / viewBox.height,
    );
    return path.transform(matrix4.storage);
  }

  @override
  bool shouldRepaint(covariant _StrokeAnimationPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _WritingPracticeStep extends StatelessWidget {
  const _WritingPracticeStep({required this.character, required this.onSuccess});

  final HanziCharacter character;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1631),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Thực hành viết',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Consumer<DrawingProvider>(
                        builder: (context, provider, child) => IconButton(
                          tooltip: 'Hoàn tác',
                          onPressed: provider.canUndo ? provider.undo : null,
                          icon: const Icon(Icons.undo_rounded, color: Colors.white70),
                        ),
                      ),
                      Consumer<DrawingProvider>(
                        builder: (context, provider, child) => IconButton(
                          tooltip: 'Xóa nét',
                          onPressed: provider.hasStrokes ? provider.clear : null,
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [Color(0xFF10193C), Color(0xFF080B1A)],
                                radius: 1,
                                center: Alignment(0, 0.3),
                              ),
                            ),
                          ),
                          CharacterOverlay(character: character.hanzi),
                          WritingPad(
                            strokePaths: character.strokeData.paths,
                            viewBox: Size(
                              character.strokeData.width.toDouble(),
                              character.strokeData.height.toDouble(),
                            ),
                            highlightColor: const Color(0xFF00E5FF),
                            baseStrokeColor: const Color(0xFF1F2B4E),
                            userStrokeColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Consumer<DrawingProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: provider.hasStrokes
                          ? const Color(0xFF78E08F)
                          : Colors.white10,
                      foregroundColor: provider.hasStrokes
                          ? Colors.black
                          : Colors.white54,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: provider.hasStrokes
                        ? () {
                            onSuccess();
                            provider.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tuyệt vời! Nét viết của bạn đã được ghi lại.')),
                            );
                          }
                        : null,
                    child: const Text('Hoàn thành nét viết'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MissingStrokeStep extends StatefulWidget {
  const _MissingStrokeStep({required this.character, required this.onSuccess});

  final HanziCharacter character;
  final Future<void> Function() onSuccess;

  @override
  State<_MissingStrokeStep> createState() => _MissingStrokeStepState();
}

class _MissingStrokeStepState extends State<_MissingStrokeStep> {
  late final List<Path> _options;
  late final int _correctOptionIndex;
  int? _selectedIndex;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final paths = widget.character.strokeData.paths;
    final rng = Random();
    final correctSvg = (paths.isEmpty ? 'M 12 12 L 12 90' : paths[rng.nextInt(max(1, paths.length))]);
    final correctPath = parseSvgPathData(correctSvg);
    final wrongPath = parseSvgPathData('M 15 15 L 95 15');
    final options = [correctPath, wrongPath]..shuffle(rng);
    _options = options;
    _correctOptionIndex = options.indexOf(correctPath);
  }

  @override
  Widget build(BuildContext context) {
    final strokeData = widget.character.strokeData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Chữ bị thiếu nét nào? Chọn đúng để hoàn thành.',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1631),
                borderRadius: BorderRadius.circular(22),
              ),
              child: CustomPaint(
                painter: _StrokeAnimationPainter(
                  progress: 1,
                  originalPaths: widget.character.strokeData.paths
                      .map(parseSvgPathData)
                      .toList(),
                  viewBox: Size(
                    strokeData.width.toDouble(),
                    strokeData.height.toDouble(),
                  ),
                  strokeColor: const Color(0xFF25315B),
                  strokeWidth: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: List.generate(_options.length, (index) {
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10193C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00CFFF) : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00CFFF).withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : const [],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomPaint(
                      painter: _StrokeAnimationPainter(
                        progress: 1,
                        originalPaths: [_options[index]],
                        viewBox: Size(
                          strokeData.width.toDouble(),
                          strokeData.height.toDouble(),
                        ),
                        strokeColor: Colors.white,
                        strokeWidth: 6,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF78E08F),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              onPressed: _selectedIndex == null || _isSubmitting
                  ? null
                  : () async {
                      final isCorrect = _selectedIndex == _correctOptionIndex;
                      if (!isCorrect) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hãy chọn đúng nét còn thiếu nhé!')),
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);
                      await widget.onSuccess();
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Hoàn thành'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({
    required this.character,
    required this.xpEarned,
  });

  final HanziCharacter character;
  final int xpEarned;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF162451), Color(0xFF10193C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFF78E08F), size: 54),
                const SizedBox(height: 16),
                Text(
                  'Hoàn thành ${character.hanzi}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '+$xpEarned XP · Tiếp tục duy trì streak nhé!',
                  style: const TextStyle(color: Color(0xFFC9D4FF)),
                ),
              ],
            ),
          ),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00CFFF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Trở lại bài học'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Tiếp tục luyện chữ khác', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
