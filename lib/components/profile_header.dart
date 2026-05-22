import 'package:flutter/material.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String subtitle;
  final Widget? badge;
  final double avatarSize;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.subtitle,
    this.badge,
    this.avatarSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        ProfileAvatar(name: username, size: avatarSize),
        const SizedBox(height: 16),
        Text(
          username,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (badge != null) ...[
          const SizedBox(height: 8),
          badge!,
        ],
      ],
    );
  }
}