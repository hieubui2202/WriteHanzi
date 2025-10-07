
import 'package:flutter/material.dart';
import 'package:myapp/src/models/user_profile.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final UserProfile userProfile;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            '$rank',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(userProfile.displayName ?? 'Người dùng ẩn danh'),
        trailing: Text(
          '${userProfile.xp} XP',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
