
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/auth/services/progress_service.dart';
import 'package:myapp/src/features/writing/providers/drawing_provider.dart';
import 'package:myapp/src/features/writing/widgets/character_overlay.dart';
import 'package:myapp/src/features/writing/widgets/writing_pad.dart';
import 'package:myapp/src/models/hanzi_character.dart';

class WritingScreen extends StatelessWidget {
  final HanziCharacter character;

  const WritingScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Luyện viết: ${character.hanzi}'),
          actions: [
            Consumer<DrawingProvider>(
              builder: (context, drawingProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: drawingProvider.undo,
                  tooltip: 'Hoàn tác',
                );
              },
            ),
            Consumer<DrawingProvider>(
              builder: (context, drawingProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: drawingProvider.clear,
                  tooltip: 'Xóa',
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Stack(
                  children: [
                    CharacterOverlay(character: character.hanzi),
                    const WritingPad(),
                  ],
                ),
              ),
            ),
            _buildCompletionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context) {
    final progressService = ProgressService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Hoàn thành'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50), // Make button wide
        ),
        onPressed: () async {
          // Award 10 XP for each character completion
          await progressService.completeCharacter(character.id, 10);

          // Show a confirmation dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tiến độ đã được lưu!'),
              backgroundColor: Colors.green,
            ),
          );

          // Pop the screen
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
