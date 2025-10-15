import 'package:flutter/material.dart';

import '../../../models/hanzi_character.dart';
import '../../../repositories/character_repository.dart';
import 'writing_screen.dart';

class WritingScreenLoader extends StatelessWidget {
  const WritingScreenLoader({
    super.key,
    required this.characterId,
    this.initialCharacter,
  });

  final String characterId;
  final HanziCharacter? initialCharacter;

  @override
  Widget build(BuildContext context) {
    if (initialCharacter != null) {
      return WritingScreen(character: initialCharacter!);
    }

    return StreamBuilder<HanziCharacter?>(
      stream: CharacterRepository().getCharacterStream(characterId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final character = snapshot.data;
        if (character == null) {
          return const Scaffold(
            body: Center(child: Text('Không tải được dữ liệu ký tự.')),
          );
        }

        return WritingScreen(character: character);
      },
    );
  }
}
