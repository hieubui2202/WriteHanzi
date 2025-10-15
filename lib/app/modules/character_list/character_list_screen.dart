import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/data/models/hanzi_model.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Hanzi> characters = Get.arguments as List<Hanzi>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ký tự trong Bài học'),
      ),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return ListTile(
            title: Text(character.character, style: const TextStyle(fontSize: 24)),
            subtitle: Text(character.pinyin),
            trailing: Text(character.meaning),
          );
        },
      ),
    );
  }
}
