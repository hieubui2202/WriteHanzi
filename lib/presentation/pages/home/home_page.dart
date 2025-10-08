import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/character.dart';
import '../../../domain/entities/unit_model.dart';
import '../../controllers/practice_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../pages/splash/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final route = GetPage(
    name: AppRoutes.home,
    page: HomePage.new,
  );

  @override
  Widget build(BuildContext context) {
    final progressController = Get.find<ProgressController>();
    final practiceController = Get.find<PracticeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('WriteHanzi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (progressController.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final units = progressController.units;
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            final characters = progressController.charactersForUnit(unit.id);
            return Card(
              color: const Color(0xFF1A1D23),
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(unit.title, style: Theme.of(context).textTheme.headlineSmall),
                        Text('XP +${unit.xpReward}')
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(unit.description, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: characters
                          .map((character) => _CharacterChip(
                                character: character,
                                unit: unit,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final character = progressController.pickNextCharacter(unit.id);
                        practiceController.start(unit, character);
                      },
                      child: Text('practice'.tr),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.review),
        icon: const Icon(Icons.refresh),
        label: Text('review'.tr),
      ),
    );
  }
}

class _CharacterChip extends StatelessWidget {
  const _CharacterChip({
    required this.character,
    required this.unit,
  });

  final Character character;
  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    final progressController = Get.find<ProgressController>();
    final progress = progressController.characterProgress(unit.id, character.hanzi);
    Color color = Colors.grey;
    if (progress.completed) {
      color = const Color(0xFF78E08F);
    } else if (progress.score > 0) {
      color = const Color(0xFFFBBF24);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            character.hanzi,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(character.pinyin),
        ],
      ),
    );
  }
}
