
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/auth/services/auth_service.dart';
import 'package:myapp/src/models/user_profile.dart';
import 'package:myapp/src/features/auth/services/progress_service.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final progressService = context.read<ProgressService>();

    if (user != null && user.isAnonymous) {
      final userProfile = authService.userProfile;
      if (userProfile == null) {
        return _buildPlaceholder(context);
      }
      return _buildProfileContent(context, colorScheme, textTheme, userProfile);
    }

    return StreamBuilder<UserProfile?>(
      stream: user != null
          ? progressService.getUserProfileStream(user.uid)
          : Stream.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a placeholder with shimmer effect while loading
          return _buildPlaceholder(context);
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        return _buildProfileContent(
          context,
          colorScheme,
          textTheme,
          snapshot.data!,
        );
      },
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    UserProfile userProfile,
  ) {
    final hasDisplayName =
        userProfile.displayName != null && userProfile.displayName!.isNotEmpty;
    final hasPhotoUrl =
        userProfile.photoURL != null && userProfile.photoURL!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
                hasPhotoUrl ? NetworkImage(userProfile.photoURL!) : null,
            child: !hasPhotoUrl
                ? const Icon(
                    Icons.person,
                    size: 35,
                  )
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDisplayName ? userProfile.displayName! : 'Xin chào!',
                  style:
                      textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  userProfile.email ?? 'Người dùng ẩn danh',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // XP and Streak
          _buildStatColumn(context, Icons.star_border, '${userProfile.xp}', 'XP'),
          const SizedBox(width: 12),
          _buildStatColumn(
              context, Icons.local_fire_department_outlined, '${userProfile.streak}', 'Streak'),
        ],
      ),
    );
  }

  // A widget for XP and Streak column
  Widget _buildStatColumn(BuildContext context, IconData icon, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }

  // Placeholder widget for loading state
  Widget _buildPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150, height: 20, color: Colors.grey),
                const SizedBox(height: 4),
                Container(width: 100, height: 14, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
