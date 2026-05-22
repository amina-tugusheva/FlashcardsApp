import 'package:flutter/material.dart';
import 'package:coursework/pages/userCardsList.dart';

class ModuleSearchTile extends StatelessWidget {
  final String moduleId;
  final String moduleName;
  final String description;
  final int cardsCount;
  final String authorId;

  const ModuleSearchTile({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.description,
    required this.cardsCount,
    required this.authorId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text('$cardsCount'),
        ),
        title: Text(moduleName),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserCardsList(
              moduleId: moduleId,
              moduleName: moduleName,
              authorId: authorId,
              isPublicStudy: true,
            ),
          ),
        ),
      ),
    );
  }
}