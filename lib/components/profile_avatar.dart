import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getEmojiByName(name),
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getEmojiByName(String name) {
    final emojis = [
      '😀', '😂', '🤓', '😎', '🥳', '🤩', '🦊', '🥰',
      '😇', '🤠', '😈', '👻', '👽', '🤖', '🎃', '🦄',
      '🐱', '🐶', '🐭', '🐹', '🐰', '😍', '🐻', '🐼',
      '🚀', '✈️', '🚗', '🚲', '🎸', '🎹', '🎤', '🎨',
    ];
    return emojis[name.toLowerCase().hashCode.abs() % emojis.length];
  }
}