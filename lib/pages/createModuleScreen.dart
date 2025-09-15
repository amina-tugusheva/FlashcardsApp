import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateModuleScreen extends StatefulWidget {
  @override
  _CreateModuleScreenState createState() => _CreateModuleScreenState();
}

class _CreateModuleScreenState extends State<CreateModuleScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> saveModule() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, введите название модуля')),
      );
      return;
    }

    await FirebaseFirestore.instance
    .collection('Users')                // корневая коллекция пользователей
    .doc(currentUser.uid)               // документ текущего пользователя
    .collection('modules')
    .add({
      'name': name,
      'description': description,
      // 'email' : currentUser.email,
      'userId': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Модуль создан!')),
    );
    Navigator.pop(context); // Возвращаемся на список модулей
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать модуль')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Название модуля'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Описание модуля (необязательно)'),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveModule,
              child: Text('Сохранить модуль'),
            ),
          ],
        ),
      ),
    );
  }
}