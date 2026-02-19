import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateModuleScreen extends StatefulWidget {
  @override
  _CreateModuleScreenState createState() => _CreateModuleScreenState();
}

// class _CreateModuleScreenState extends State<CreateModuleScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final currentUser = FirebaseAuth.instance.currentUser!;

//   bool isPublic = false;

//   Future<void> saveModule() async {
//     final name = nameController.text.trim();
//     final description = descriptionController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Пожалуйста, введите название модуля')),
//       );
//       return;
//     }

//     await FirebaseFirestore.instance
//     .collection('Users')                // корневая коллекция пользователей
//     .doc(currentUser.uid)               // документ текущего пользователя
//     .collection('modules')
//     .add({
//       'name': name,
//       'description': description,
//       // 'email' : currentUser.email,
//       'userId': currentUser.uid,
//       'isPublic': isPublic,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Модуль создан!')),
//     );
//     Navigator.pop(context); // Возвращаемся на список модулей
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Создать модуль')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Название модуля'),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: descriptionController,
//               decoration: InputDecoration(labelText: 'Описание модуля (необязательно)'),
//               maxLines: 3,
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: saveModule,
//               child: Text('Сохранить модуль'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _CreateModuleScreenState extends State<CreateModuleScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  
  // ✅ Переключатель приватности
  bool isPublic = false;

  Future<void> saveModule() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите название модуля')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .add({
        'name': name,
        'description': description.isEmpty ? null : description,
        'userId': currentUser.uid,
        'isPublic': isPublic, // ✅ Приватный/публичный
        'cardsCount': 0, // ✅ Счетчик карточек
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPublic 
                ? 'Публичный модуль создан!' 
                : 'Приватный модуль создан!'),
            backgroundColor: isPublic ? Colors.green : Colors.blue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка создания: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyles = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать модуль'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Название
            TextField(
              controller: nameController,
              style: textStyles.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Название модуля *',
                labelStyle: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                prefixIcon: Icon(Icons.book, color: colors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Описание
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: textStyles.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Описание (необязательно)',
                labelStyle: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                prefixIcon: Icon(Icons.description, color: colors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ✅ Выбор приватности
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Видимость модуля',
                      style: textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // ✅ Переключатель
                    Row(
                      children: [
                        Switch(
                          value: isPublic,
                          activeColor: colors.primary,
                          onChanged: (value) {
                            setState(() {
                              isPublic = value;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPublic ? 'Публичный' : 'Приватный',
                                style: textStyles.titleMedium,
                              ),
                              Text(
                                isPublic 
                                    ? 'Другие смогут найти и скачать модуль' 
                                    : 'Виден только вам',
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ✅ Кнопка сохранения
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: Icon(isPublic ? Icons.public : Icons.lock),
                label: Text(
                  isPublic ? 'Создать публичный модуль' : 'Создать приватный модуль'
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: saveModule,
              ),
            ),
          ],
        ),
      ),
    );
  }
}