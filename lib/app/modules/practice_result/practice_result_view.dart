import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'practice_result_controller.dart';

class PracticeResultPage extends GetView<PracticeResultController> {
  const PracticeResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả luyện tập'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildStats(context),
              const SizedBox(height: 24),
              _buildSteps(context),
              const Spacer(),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
        const SizedBox(height: 12),
        Text(
          'Hoàn thành bài luyện chữ!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          controller.character.word.isNotEmpty
              ? controller.character.word
              : controller.character.character,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildStatRow(Icons.star, 'XP', '+${controller.xp}'),
          const Divider(height: 24),
          _buildStatRow(Icons.speed, 'Điểm', '${controller.score}/100'),
          const Divider(height: 24),
          _buildStatRow(Icons.error_outline, 'Sai sót', '${controller.mistakes}'),
          const Divider(height: 24),
          _buildStatRow(Icons.timer, 'Thời gian', controller.formattedDuration),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSteps(BuildContext context) {
    final steps = controller.completedSteps.entries.toList();
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các bước đã hoàn thành',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: steps
                .map(
                  (entry) => Chip(
                    avatar: Icon(
                      entry.value ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: entry.value ? Colors.green : Colors.grey,
                    ),
                    label: Text(_stepLabel(entry.key)),
                    backgroundColor:
                        entry.value ? Colors.green.shade50 : Colors.grey.shade200,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _stepLabel(String key) {
    switch (key) {
      case 'trace':
        return 'Vẽ đủ nét';
      case 'missing':
        return 'Hoàn thiện nét';
      case 'build':
        return 'Ghép chữ';
      default:
        return key;
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Obx(() {
      final saving = controller.isSaving.value;
      return ElevatedButton.icon(
        onPressed: saving ? null : controller.finishPractice,
        icon: saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.home),
        label: Text(saving ? 'Đang lưu...' : 'Về trang chủ'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    });
  }
}
