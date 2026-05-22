import 'package:flutter/material.dart';
import 'package:coursework/components/module_model.dart';

class ModuleListTile extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback onTap;
  final String? authorName;

  const ModuleListTile({
    super.key,
    required this.module,
    required this.onTap,
    this.authorName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPublic = module.isPublic ?? false;
    final isSaved = module.isSaved ?? false;
    final progress = module.overallProgress.clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isPublic ? scheme.primaryContainer : scheme.surfaceVariant,
          child: Text('${module.cardsCount ?? 0}'),
        ),
        title: Text(module.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (module.description?.isNotEmpty == true)
              Text(
                module.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text('${(progress * 100).round()}%'),
            if (isSaved && authorName != null) Text('Автор: $authorName'),
          ],
        ),
        trailing: Icon(isSaved ? Icons.download : (isPublic ? Icons.public : Icons.lock)),
        onTap: onTap,
      ),
    );
  }
}