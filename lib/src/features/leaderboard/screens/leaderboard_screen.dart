
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/leaderboard/services/leaderboard_service.dart';
import 'package:myapp/src/models/user_profile.dart';
import 'package:myapp/src/features/leaderboard/widgets/leaderboard_tile.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboardService = LeaderboardService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng xếp hạng'),
      ),
      body: StreamProvider<List<UserProfile>>.value(
        value: leaderboardService.getLeaderboard(),
        initialData: const [],
        child: Consumer<List<UserProfile>>(
          builder: (context, users, child) {
            if (users.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return LeaderboardTile(
                  rank: index + 1,
                  userProfile: user,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
