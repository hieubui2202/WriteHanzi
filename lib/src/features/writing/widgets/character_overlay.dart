
import 'package:flutter/material.dart';

class CharacterOverlay extends StatelessWidget {
  final String character;

  const CharacterOverlay({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        character,
        style: TextStyle(
          fontSize: 200,
          color: Colors.grey.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
