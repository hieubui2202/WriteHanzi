import 'package:characters/characters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/modules/home/home_controller.dart';
import 'package:myapp/app/routes/app_pages.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  Color get _backgroundTop => const Color(0xFF111629);
  Color get _backgroundBottom => const Color(0xFF0B0F18);
  Color get _primary => const Color(0xFF18E06F);

  @override
  Widget build(BuildContext context) {
    final characters = (Get.arguments as List<HanziCharacter>?) ?? const <HanziCharacter>[];
    final homeController = Get.find<HomeController>();

    if (characters.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_backgroundTop, _backgroundBottom],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'Không có ký tự nào trong bài học này.',
                style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundTop, _backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Ký tự trong bài học',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final progressMap = homeController.profile.value?.progress ?? const <String, dynamic>{};
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      final entry = progressMap[character.id];
                      final completed = homeController.isCharacterCompleted(character);
                      final score = _readInt(entry, 'score');
                      final mistakes = _readInt(entry, 'mistakes');
                      final lastReview = _readTimestamp(entry, 'lastReview');
                      final display = character.word.isNotEmpty ? character.word : character.character;
                      final subtitle = '${character.character} • ${character.pinyin}';
                      return _CharacterCard(
                        title: display,
                        subtitle: subtitle,
                        meaning: character.meaning,
                        completed: completed,
                        score: score,
                        mistakes: mistakes,
                        lastReview: lastReview,
                        primary: _primary,
                        onPractice: () {
                          Get.toNamed(Routes.writingPractice, arguments: character.id);
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: characters.length,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _readInt(dynamic entry, String key) {
    if (entry is Map<String, dynamic>) {
      final value = entry[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
    }
    return 0;
  }

  String? _readTimestamp(dynamic entry, String key) {
    if (entry is Map<String, dynamic>) {
      final value = entry[key];
      DateTime? date;
      if (value is Timestamp) {
        date = value.toDate();
      } else if (value is DateTime) {
        date = value;
      } else if (value is String && value.isNotEmpty) {
        return value;
      }
      if (date != null) {
        final formatter = DateFormat('dd/MM • HH:mm');
        return formatter.format(date);
      }
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.title,
    required this.subtitle,
    required this.meaning,
    required this.completed,
    required this.score,
    required this.mistakes,
    required this.lastReview,
    required this.primary,
    required this.onPractice,
  });

  final String title;
  final String subtitle;
  final String meaning;
  final bool completed;
  final int score;
  final int mistakes;
  final String? lastReview;
  final Color primary;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final pillColor = completed ? primary : Colors.white.withOpacity(0.12);
    final pillLabel = completed ? 'Đã hoàn thành' : 'Chưa luyện';
    final displayScore = completed ? '$score điểm' : 'Chưa có điểm';
    final displayMistakes = mistakes > 0 ? '$mistakes lỗi' : 'Hoàn hảo';
    final initials = title.trim().isNotEmpty ? title.trim().characters.first : '?';

    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    pillLabel,
                    style: TextStyle(
                      color: completed ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              meaning,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(icon: Icons.emoji_events_outlined, label: displayScore),
                const SizedBox(width: 8),
                _infoChip(icon: Icons.fact_check_outlined, label: displayMistakes),
                const SizedBox(width: 8),
                if (lastReview != null)
                  _infoChip(icon: Icons.history, label: lastReview!),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPractice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: completed ? Colors.white.withOpacity(0.12) : primary,
                  foregroundColor: completed ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(completed ? 'Ôn lại' : 'Luyện ngay',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
