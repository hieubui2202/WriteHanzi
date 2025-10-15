import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LessonStep {
  const LessonStep({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const List<LessonStep> defaultLessonSteps = [
  LessonStep(
    title: 'Select the pronunciation',
    description: 'Match the hanzi with its correct pinyin audio.',
    icon: Icons.hearing,
  ),
  LessonStep(
    title: 'Select the meaning',
    description: 'Choose the translation that best fits the hanzi.',
    icon: Icons.translate,
  ),
  LessonStep(
    title: 'Trace the hanzi',
    description: 'Follow the guideline to memorise the stroke order.',
    icon: Icons.gesture,
  ),
  LessonStep(
    title: 'Finish the hanzi',
    description: 'Fill in the missing strokes to reinforce recall.',
    icon: Icons.edit,
  ),
  LessonStep(
    title: 'Write the hanzi',
    description: 'Draw the character on your own to gain confidence.',
    icon: Icons.brush,
  ),
  LessonStep(
    title: 'Build the hanzi',
    description: 'Assemble radicals and components from memory.',
    icon: Icons.extension,
  ),
];

class CharacterLessonScreen extends StatelessWidget {
  const CharacterLessonScreen({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson for $characterId'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('characters').doc(characterId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong loading this lesson.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Character data not found.'));
          }

          final characterData = snapshot.data!.data()!;
          final meaning = characterData['meaning'] as String? ?? '';
          final pinyin = characterData['pinyin'] as String? ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      characterId,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$meaning  •  $pinyin',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete each step to master this character.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: defaultLessonSteps.length,
                  itemBuilder: (context, index) {
                    final step = defaultLessonSteps[index];
                    return _LessonStepCard(
                      stepNumber: index + 1,
                      step: step,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonStepCard extends StatelessWidget {
  const _LessonStepCard({required this.stepNumber, required this.step});

  final int stepNumber;
  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              foregroundColor: theme.colorScheme.primary,
              child: Text(stepNumber.toString()),
            ),
            const Spacer(),
            Icon(step.icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              step.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              step.description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
