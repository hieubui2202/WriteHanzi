import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/routes/app_routes.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_submitted) {
        _submitted = true;
        await controller.persistResult();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final char = controller.character.value;
    return Padding(
      padding: practicePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF151A21),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: practicePrimary, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Great job!',
                  style: bodyStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                if (char != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${char.character} • ${char.pinyin}',
                      style: bodyStyle(fontSize: 18),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildSummaryRow('XP earned', '+${controller.xpEarned}'),
                _buildSummaryRow('Score', '${controller.score}%'),
                _buildSummaryRow('Mistakes', controller.mistakes.value.toString()),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildCompletionChips(),
          const Spacer(),
          ElevatedButton(
            style: primaryButtonStyle,
            onPressed: () => Get.offAllNamed(Routes.home),
            child: const Text('BACK TO HOME'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              final charId = char?.id;
              if (charId != null) {
                controller.load(charId);
                controller.currentIndex.value = 0;
              }
            },
            child: const Text('Practice again'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bodyStyle(fontSize: 16)),
          Text(
            value,
            style: bodyStyle(fontSize: 16, fontWeight: FontWeight.w700).copyWith(color: practicePrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChips() {
    final flags = controller.completionFlags;
    return Wrap(
      spacing: 12,
      children: [
        _chip('Trace', flags['trace'] ?? false),
        _chip('Missing strokes', flags['missing'] ?? false),
        _chip('Build parts', flags['build'] ?? false),
      ],
    );
  }

  Widget _chip(String label, bool value) {
    return Chip(
      label: Text(
        label,
        style: bodyStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      backgroundColor: value ? practicePrimary.withOpacity(0.2) : Colors.white12,
      shape: StadiumBorder(side: BorderSide(color: value ? practicePrimary : Colors.white24)),
    );
  }
}
