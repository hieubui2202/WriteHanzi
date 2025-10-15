import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HanziCharacter> characters =
        (Get.arguments as List<HanziCharacter>?) ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ký tự trong Bài học'),
      ),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          final display = character.word.isNotEmpty
              ? character.word
              : character.character;
          return ListTile(
            title: Text(display, style: const TextStyle(fontSize: 24)),
            subtitle: Text('${character.character} • ${character.pinyin}'),
            trailing: Text(character.meaning),
          );
        },
      ),
    );
  }
}
