import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';

class SelectMeaningPage extends StatefulWidget {
  const SelectMeaningPage({super.key, required this.character});

  final HanziCharacter character;

  @override
  State<SelectMeaningPage> createState() => _SelectMeaningPageState();
}

class _SelectMeaningPageState extends State<SelectMeaningPage>
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
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choices = controller.meaningChoices;
    return Padding(
      padding: practicePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.character.character,
            style: titleStyle(context).copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...choices.map(_buildChoice).toList(),
          const Spacer(),
          if (_showFeedback)
            Text(
              _isCorrect ? 'Nice!' : 'Oops, try again!'.toUpperCase(),
              textAlign: TextAlign.center,
              style: bodyStyle(fontSize: 16, fontWeight: FontWeight.w700).copyWith(
                color: _isCorrect ? practicePrimary : Colors.redAccent,
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: primaryButtonStyle,
            onPressed: _isCorrect ? controller.goToNext : null,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  Widget _buildChoice(String value) {
    final isSelected = _selected == value;
    final isCorrectChoice = value == widget.character.meaning;
    final borderColor = _isCorrect && isSelected
        ? practicePrimary
        : isSelected
            ? Colors.redAccent
            : Colors.white12;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeController.value * math.pi * 6) * 8;
        final offset = isSelected && !_isCorrect ? shake : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
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
      controller.markStepCompleted(PracticeStep.selectMeaning, passed: true);
    } else {
      controller.markStepCompleted(PracticeStep.selectMeaning, passed: false);
      _shakeController
        ..reset()
        ..forward();
    }
  }
}
