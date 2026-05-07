import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Модули $targetUsername'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
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
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getEmojiByName(targetUsername),  
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // ИМЯ
                Text(
                  targetUsername,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 4),
                
                // // Загрузка email 
                // StreamBuilder<DocumentSnapshot>(
                //   stream: FirebaseFirestore.instance
                //       .collection('Users')
                //       .doc(targetUserId)
                //       .snapshots(),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData || !snapshot.data!.exists) {
                //       return Text(
                //         'user@example.com',
                //         style: theme.textTheme.bodyMedium?.copyWith(
                //           color: scheme.onPrimaryContainer.withOpacity(0.7),
                //         ),
                //       );
                //     }
                    
                //     final userData = snapshot.data!.data() as Map<String, dynamic>?;
                //     final email = userData?['email'] ?? 'user@example.com';
                    
                //     return Text(
                //       email,
                //       style: theme.textTheme.bodyMedium?.copyWith(
                //         color: scheme.onPrimaryContainer.withOpacity(0.7),
                //       ),
                //     );
                //   },
                // ),
                
                // const SizedBox(height: 8),
                
                // Счетчик публичных модулей
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(targetUserId)
                      .collection('modules')
                      .where('isPublic', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count публичных модулей',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // МОДУЛИ
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
    );
  }
  String _getEmojiByName(String name) {
    final emojis = [
      '😀', '😂', '🤓', '😎', '🥳', '🤩', '😍', '🥰', '😇', '🤠',
      '😈', '👻', '👽', '🤖', '🎃', '🦄', '🐱', '🐶', '🐭', '🐹',
      '🐰', '🦊', '🐻', '🐼', '🚀', '✈️', '🚗', '🚲', '🎸', '🎹',
      '🎤', '🎨', '📚', '💻', '⚽', '🎮'
    ];
    return emojis[name.toLowerCase().hashCode.abs() % emojis.length];
  }
}
