import 'package:flutter/material.dart';
import '../../../models/hanzi_character.dart';
import '../logic/writing_recognizer.dart';
import '../widgets/writing_canvas.dart';

class WritingPracticeScreen extends StatefulWidget {
  final HanziCharacter? character;

  const WritingPracticeScreen({super.key, this.character});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  late final HanziCharacter _character;
  final GlobalKey<WritingCanvasState> _canvasKey = GlobalKey<WritingCanvasState>();

  @override
  void initState() {
    super.initState();
    _character = widget.character ?? HanziCharacter.demo();
  }

  void _checkWriting() {
    final userStrokes = _canvasKey.currentState?.strokes;
    if (userStrokes != null) {
      final score =
          WritingRecognizer.calculateScore(userStrokes, _character.strokeData);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kết quả'),
          content: Text('Điểm của bạn: ${score.toStringAsFixed(1)}%'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _undoStroke() {
    _canvasKey.currentState?.undoStroke();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Luyện viết: ${_character.hanzi}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _canvasKey.currentState?.clearCanvas();
            },
            tooltip: 'Clear Canvas',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_character.pinyin} - ${_character.meaning}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8.0),
                  // Add a faint background of the character
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://raw.githubusercontent.com/skishore/makemeahanzi/master/graphics/${_character.hanzi}.png',
                    ),
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withValues(alpha: 0.2),
                      BlendMode.dstIn,
                    ),
                  ),
                ),
                child: WritingCanvas(key: _canvasKey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _undoStroke, child: const Text('Undo')),
                ElevatedButton(onPressed: _checkWriting, child: const Text('Check')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
