import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';

class SelectPronunciationPage extends StatefulWidget {
  const SelectPronunciationPage({super.key, required this.character});

  final HanziCharacter character;

  @override
  State<SelectPronunciationPage> createState() => _SelectPronunciationPageState();
}

class _SelectPronunciationPageState extends State<SelectPronunciationPage>
    with SingleTickerProviderStateMixin {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();

  String? _selected;
  bool _isCorrect = false;
  bool _showFeedback = false;
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.playAudio();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choices = controller.pronunciationChoices;
    return Padding(
      padding: practicePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.character.word.isNotEmpty ? widget.character.word : widget.character.character,
            style: titleStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...choices.map((choice) => _buildChoice(choice)).toList(),
          const Spacer(),
          if (_showFeedback)
            Text(
              _isCorrect ? 'Amazing!' : 'Try again!'.toUpperCase(),
              textAlign: TextAlign.center,
              style: bodyStyle(fontSize: 16, fontWeight: FontWeight.w700).copyWith(
                color: _isCorrect ? practicePrimary : Colors.redAccent,
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: primaryButtonStyle,
            onPressed: _isCorrect
                ? () {
                    controller.goToNext();
                  }
                : null,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  Widget _buildChoice(String value) {
    final isSelected = _selected == value;
    final isCorrectChoice = value == widget.character.pinyin;
    final showCorrect = _isCorrect && isSelected;

    final borderColor = showCorrect
        ? practicePrimary
        : isSelected
            ? Colors.redAccent
            : Colors.white12;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeController.value * math.pi * 6) * 8;
        final offset = isSelected && !_isCorrect ? shake : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _onChoiceTapped(value, isCorrectChoice),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isSelected ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: bodyStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _onChoiceTapped(String value, bool isCorrectChoice) {
    setState(() {
      _selected = value;
      _isCorrect = isCorrectChoice;
      _showFeedback = true;
    });
    if (isCorrectChoice) {
      controller.markStepCompleted(PracticeStep.selectPronunciation, passed: true);
    } else {
      controller.markStepCompleted(PracticeStep.selectPronunciation, passed: false);
      _shakeController
        ..reset()
        ..forward();
    }
  }
}
