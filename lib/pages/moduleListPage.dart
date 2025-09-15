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

            // .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: 
            Text('Ошибка загрузки данных: ${snapshot.error}')
            
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Модулей пока нет. Создайте первый!${currentUser.uid}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final modules = snapshot.data!.docs.map((doc) => ModuleModel.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(module.name),
                  subtitle: Text(module.description),
                  onTap: () {
                    // Переход на экран со списком карточек для этого модуля
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
                  trailing: IconButton(
                  icon: Icon(
                    Icons.delete, 
                    // color: Colors.red
                    ),
                  tooltip: 'Удалить модуль',
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Удалить модуль?'),
                        content: Text('Все карточки внутри модуля тоже будут удалены. Продолжить?'),
                        actions: [
                          TextButton(
                            child: Text('Отмена'),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text('Удалить', style: TextStyle(color: Colors.red)),
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
                      // Удалить все карточки модуля
                      final cardsSnapshot = await moduleRef.collection('user_cards').get();
                      for (final card in cardsSnapshot.docs) {
                        await card.reference.delete();
                      }
                      // Удалить сам модуль
                      await moduleRef.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Модуль и все карточки удалены')),
                      );
                    }
                  },
                ),
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
