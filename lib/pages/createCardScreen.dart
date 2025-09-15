import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register.dart';

final currentUser = FirebaseAuth.instance.currentUser!;

class CreateCardScreen extends StatefulWidget {
  final String moduleId; // ID модуля, к которому привязываем карточку

  const CreateCardScreen({Key? key, required this.moduleId}) : super(key: key);

  @override
  _CreateCardScreenState createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final TextEditingController termController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!; // получаем текущего пользователя

  Future<void> saveCard() async {
    final term = termController.text.trim();
    final definition = definitionController.text.trim();
    final userId = currentUser.uid;

    if (term.isEmpty || definition.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    await FirebaseFirestore.instance
    .collection('Users')
    .doc(currentUser.uid)
    .collection('modules')
    .doc(widget.moduleId)                 
    .collection('user_cards')
    .add
    ({
      'term': term,
      'definition': definition,
      'userId': userId,
      'moduleId': widget.moduleId, //Привязка к модулю
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Карточка сохранена')),
    );
    termController.clear();
    definitionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать карточку')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: termController,
              decoration: InputDecoration(labelText: 'Термин'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: definitionController,
              decoration: InputDecoration(labelText: 'Определение'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveCard,
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
