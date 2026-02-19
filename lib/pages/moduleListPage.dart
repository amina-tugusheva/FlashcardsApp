// screens/module_list_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/module_model.dart'; // import ModuleModel
import 'createModuleScreen.dart'; 
import 'userCardsList.dart'; 
import 'createCardScreen.dart'; 

class ModuleListPage extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои модули')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            // .collection('modules')
            // // .where('email', isEqualTo: currentUser.email)
            // .where('userId', isEqualTo: currentUser.uid)
            .collection('Users')
            .doc(currentUser.uid)
            .collection('modules')

            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: 
            Text('Ошибка загрузки данных: ${snapshot.error}')
            
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Модулей пока нет. Создайте первый!${currentUser.uid}'));
          }
          

          final modules = snapshot.data!.docs.map((doc) => ModuleModel.fromFirestore(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];

              final isPublic = module.isPublic ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isPublic 
                        ? Theme.of(context).colorScheme.primaryContainer 
                        : Theme.of(context).colorScheme.surfaceVariant,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Text(
                      '${module.cardsCount ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    module.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (module.description?.isNotEmpty == true)
                        Text(module.description!),
                      // Text('Карточек: ${module.cardsCount ?? 0}'),
                      if (isPublic)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Публичный',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPublic ? Icons.public : Icons.lock,
                        color: isPublic 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Удалить модуль',
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Удалить модуль?'),
                              content: const Text(
                                'Все карточки внутри модуля тоже будут удалены. Продолжить?'
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Отмена'),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldDelete == true) {
                            final moduleRef = FirebaseFirestore.instance
                                .collection('Users')
                                .doc(currentUser.uid)
                                .collection('modules')
                                .doc(module.id);
                            
                            // Удалить карточки
                            final cardsSnapshot = await moduleRef.collection('user_cards').get();
                            for (final card in cardsSnapshot.docs) {
                              await card.reference.delete();
                            }
                            // Удалить модуль
                            await moduleRef.delete();
                            
                            // if (mounted) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(content: Text('Модуль удалён')),
                            //   );
                            // }
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserCardsList(
                          moduleId: module.id,
                          moduleName: module.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Переход на экран создания нового модуля
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateModuleScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Создать новый модуль',
      ),
    );
  }
}
