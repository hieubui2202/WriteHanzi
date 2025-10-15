
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/unit.dart';
import '../../../models/hanzi_character.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/character_repository.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/auth/services/progress_service.dart';

class UnitDetailsScreen extends StatelessWidget {
  final Unit unit;

  const UnitDetailsScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(unit.title),
      ),
      body: StreamBuilder<List<HanziCharacter>>(
        stream: CharacterRepository().getCharactersForUnit(unit),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có ký tự nào trong bài này.'));
          }

          final characters = snapshot.data!;

          return StreamBuilder<UserProfile?>(
            stream: user != null ? ProgressService().getUserProfileStream(user.uid) : Stream.value(null),
            builder: (context, userProfileSnapshot) {
              final userProfile = userProfileSnapshot.data;

              return ListView.builder(
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final progressKey = character.progressKey;
                  final bool isCompleted =
                      userProfile?.progress[progressKey] == 'completed' ||
                          userProfile?.progress[character.hanzi] == 'completed';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Text(character.hanzi, style: const TextStyle(fontSize: 32)),
                      title: Text(character.pinyin),
                      subtitle: Text(character.meaning),
                      trailing: isCompleted
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to the writing screen, passing the character object
                        context.go('/unit/${unit.id}/write/$progressKey', extra: character);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
