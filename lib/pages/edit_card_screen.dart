import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditCardScreen extends StatefulWidget {
  final String moduleId;
  final String cardId;
  final String initialTerm;
  final String initialDefinition;

  const EditCardScreen({
    Key? key,
    required this.moduleId,
    required this.cardId,
    required this.initialTerm,
    required this.initialDefinition,
  }) : super(key: key);

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController termController;
  late TextEditingController definitionController;

  @override
  void initState() {
    super.initState();
    termController = TextEditingController(text: widget.initialTerm);
    definitionController = TextEditingController(text: widget.initialDefinition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Редактировать карточку')),
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
              onPressed: () async {
                final newTerm = termController.text.trim();
                final newDefinition = definitionController.text.trim();
                if (newTerm.isEmpty || newDefinition.isEmpty) return;

                await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('modules')
                  .doc(widget.moduleId)
                  .collection('user_cards')
                  .doc(widget.cardId)
                  .update({
                    'term': newTerm,
                    'definition': newDefinition,
                  });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Карточка обновлена')),
                );
              },
              child: Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }
}
