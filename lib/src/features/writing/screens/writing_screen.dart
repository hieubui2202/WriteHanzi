
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hanzi_character.dart';
import '../../../features/auth/services/progress_service.dart';
import '../providers/drawing_provider.dart';
import '../widgets/character_overlay.dart';
import '../widgets/writing_pad.dart';

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
    final progressService = Provider.of<ProgressService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Hoàn thành'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50), // Make button wide
        ),
        onPressed: () async {
          final progressKey =
              character.id.isNotEmpty ? character.id : character.hanzi;

          try {
            await progressService.completeCharacter(progressKey, 10);
          } catch (error) {
            if (navigator.mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Không thể lưu tiến độ: $error'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return;
          }

          if (!navigator.mounted) {
            return;
          }

          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Tiến độ đã được lưu!'),
              backgroundColor: Colors.green,
            ),
          );

          navigator.pop();
        },
      ),
    );
  }
}
