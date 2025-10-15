import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';

class TypeHanziPage extends StatefulWidget {
  const TypeHanziPage({super.key, required this.character});

  final HanziCharacter character;

  @override
  State<TypeHanziPage> createState() => _TypeHanziPageState();
}

class _TypeHanziPageState extends State<TypeHanziPage>
    with SingleTickerProviderStateMixin {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  bool _isCorrect = false;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.character.word.isNotEmpty
        ? widget.character.word
        : widget.character.character;
    return Padding(
      padding: practicePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            display,
            textAlign: TextAlign.center,
            style: titleStyle(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Type the character exactly as it appears.',
            textAlign: TextAlign.center,
            style: bodyStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = math.sin(_shakeController.value * math.pi * 6) * 8;
              return Transform.translate(
                offset: Offset(_isCorrect ? 0 : offset, 0),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _showFeedback
                      ? (_isCorrect ? practicePrimary : Colors.redAccent)
                      : Colors.white12,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    cursorColor: practicePrimary,
                    style: const TextStyle(
                      fontSize: 36,
                      fontFamily: 'NotoSansSC',
                      color: practiceText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type here',
                      hintStyle: bodyStyle(fontSize: 18).copyWith(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) {
                      if (_showFeedback) {
                        setState(() {
                          _showFeedback = false;
                          _isCorrect = false;
                        });
                      }
                    },
                    onSubmitted: (_) => _validate(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.character.pinyin,
                    style: bodyStyle(fontSize: 15).copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _validate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: practicePrimary,
                    side: const BorderSide(color: practicePrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Check'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _isCorrect = false;
                      _showFeedback = false;
                    });
                    _focusNode.requestFocus();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: practiceText,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_showFeedback)
            Text(
              _isCorrect ? 'Great typing!' : 'Try again',
              textAlign: TextAlign.center,
              style: bodyStyle(fontSize: 16, fontWeight: FontWeight.w700).copyWith(
                color: _isCorrect ? practicePrimary : Colors.redAccent,
              ),
            ),
          const Spacer(),
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

  void _validate() {
    final answers = <String>{widget.character.character.trim()};
    if (widget.character.word.trim().isNotEmpty) {
      answers.add(widget.character.word.trim());
    }
    final typed = _textController.text.trim();
    final success = answers.contains(typed);
    setState(() {
      _isCorrect = success;
      _showFeedback = true;
    });
    controller.markStepCompleted(PracticeStep.typeOnKeyboard, passed: success);
    if (!success) {
      _shakeController
        ..reset()
        ..forward();
    }
  }
}
