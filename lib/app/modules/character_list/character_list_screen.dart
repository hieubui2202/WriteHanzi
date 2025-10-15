import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/routes/app_pages.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HanziCharacter> characters =
        (Get.arguments as List<HanziCharacter>?) ?? const [];

    if (characters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ký tự trong Bài học'),
        ),
        body: const Center(
          child: Text('Không có ký tự nào trong bài học này.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ký tự trong Bài học'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          final display = character.word.isNotEmpty
              ? character.word
              : character.character;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              onTap: () => Get.toNamed(
                Routes.writingPractice,
                arguments: character,
              ),
              title: Text(
                display,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${character.character} • ${character.pinyin}\n${character.meaning}',
              ),
              trailing: const Icon(Icons.draw, color: Colors.deepPurple),
            ),
          );
        },
      ),
    );
  }
}
