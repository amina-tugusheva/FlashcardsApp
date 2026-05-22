import 'package:flutter/material.dart';
import 'package:coursework/pages/other_user_prifile_page.dart';

class UserSearchTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String avatarUrl;

  const UserSearchTile({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildAvatar(context),
        title: Text(name),
        subtitle: Text(email.isNotEmpty ? email : 'Модули доступны'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicUserProfilePage(
              targetUserId: userId,
              targetUsername: name,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    return CircleAvatar(
      backgroundColor: scheme.primaryContainer,
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
    );
  }
}