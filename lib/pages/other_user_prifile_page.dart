import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursework/components/my_button.dart';
import 'package:coursework/components/text_box.dart'; // предполагаю, что MyTextBox это text_box.dart
import 'package:coursework/theme/theme_providor.dart';
import 'package:provider/provider.dart';


import 'package:coursework/components/module_model.dart';
import 'userCardsList.dart';

class PublicUserProfilePage extends StatelessWidget {
  final String targetUserId;
  final String targetUsername;

  const PublicUserProfilePage({
    Key? key,
    required this.targetUserId,
    required this.targetUsername,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Модули $targetUsername'),
        // ❌ БЕЗ кнопки создания (чужие модули)
      ),
      body: Column(
        children: [
          // ✅ ИМЯ ПОЛЬЗОВАТЕЛЯ
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Text(
                  targetUsername,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 4),
                // Text(
                //   '@$targetUsername',
                //   style: TextStyle(
                //     color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                //   ),
                // ),
              ],
            ),
          ),
          
          // ✅ МОДУЛИ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(targetUserId)
                  .collection('modules')
                  .where('isPublic', isEqualTo: true)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Публичных модулей нет'),
                      ],
                    ),
                  );
                }

                final modules = snapshot.data!.docs
                    .map((doc) => ModuleModel.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text('${module.cardsCount ?? 0}'),
                        ),
                        title: Text(module.name),
                        subtitle: Text(module.description ?? ''),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserCardsList(
                                moduleId: module.id,
                                moduleName: module.name,
                                authorId: targetUserId,
                                isPublicStudy: true, 
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
          ),
        ],
      ),
    //   body: StreamBuilder<QuerySnapshot>(
    //     stream: FirebaseFirestore.instance
    //         .collection('Users')
    //         .doc(otherUserId)  // 
    //         .collection('modules')
    //         .where('isPublic', isEqualTo: true)  //  Только публичные
    //         .orderBy('createdAt', descending: true)
    //         .snapshots(),
    //         builder: (context, snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //         return Center(child: CircularProgressIndicator());
    //       }

    //       if (snapshot.hasError) {
    //         return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
    //       }

    //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    //         return Center(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Icon(Icons.lock_open_outlined, size: 64, color: Colors.grey),
    //               SizedBox(height: 16),
    //               Text('У $otherUserName нет публичных модулей'),
    //             ],
    //           ),
    //         );
    //       }

    //       final modules = snapshot.data!.docs.map((doc) => ModuleModel.fromFirestore(doc)).toList();

    //       return ListView.builder(
    //         padding: const EdgeInsets.all(16),
    //         itemCount: modules.length,
    //         itemBuilder: (context, index) {
    //           final module = modules[index];
    //           final isPublic = module.isPublic ?? false; // Всегда true из-за where

    //           return Card(
    //             margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    //             child: ListTile(
    //               contentPadding: const EdgeInsets.all(16),
    //               leading: CircleAvatar(
    //                 backgroundColor: isPublic
    //                     ? Theme.of(context).colorScheme.primaryContainer
    //                     : Theme.of(context).colorScheme.surfaceVariant,
    //                 foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    //                 child: Text(
    //                   '${module.cardsCount ?? 0}',
    //                   style: const TextStyle(fontWeight: FontWeight.bold),
    //                 ),
    //               ),
    //               title: Text(
    //                 module.name,
    //                 style: Theme.of(context).textTheme.titleMedium,
    //               ),
    //               subtitle: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   if (module.description?.isNotEmpty == true) Text(module.description!),
    //                   if (isPublic)
    //                     Container(
    //                       margin: const EdgeInsets.only(top: 4),
    //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    //                       decoration: BoxDecoration(
    //                         color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    //                         borderRadius: BorderRadius.circular(12),
    //                       ),
    //                       child: Text(
    //                         'Публичный',
    //                         style: TextStyle(
    //                           color: Theme.of(context).colorScheme.primary,
    //                           fontSize: 12,
    //                         ),
    //                       ),
    //                     ),
    //                 ],
    //               ),
    //               trailing: Row(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Icon(
    //                     isPublic ? Icons.public : Icons.lock,
    //                     color: isPublic
    //                         ? Theme.of(context).colorScheme.primary
    //                         : Theme.of(context).colorScheme.onSurfaceVariant,
    //                     size: 20,
    //                   ),
    //                   // ❌ БЕЗ кнопки удаления
    //                 ],
    //               ),
    //               onTap: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => UserCardsList(
    //                       moduleId: module.id,
    //                       moduleName: module.name,
    //                       // ✅ isPublic: true, targetUserId: targetUserId (если нужно)
    //                     ),
    //                   ),
    //                 );
    //               },
    //             ),
    //           );
    //         },
    //       );
              
    //         },
    //   ),

    );
  }
}
