import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'userCardsList.dart';
import 'test_result_screen.dart';
import 'createModuleScreen.dart'; 
import 'moduleListPage.dart';
import 'createCardScreen.dart';


import 'package:coursework/components/module_model.dart'; // import ModuleModel


class TestScreen extends StatefulWidget {
  final String moduleId;
  // final String moduleName;
  final List<CardModel> cards;

  const TestScreen({
    Key? key,
    required this.moduleId,
    // required this.moduleName,
    required this.cards,
  }) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int currentIndex = 0;
  int correctCount = 0;
  List<bool> results = [];
  TextEditingController answerController = TextEditingController();
  
  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void checkAnswer() {
    final card = widget.cards[currentIndex];
    final userAnswer = answerController.text.trim().toLowerCase();
    final correctAnswer = card.definition.trim().toLowerCase();

    bool isCorrect = userAnswer == correctAnswer;

    if (isCorrect) {
      correctCount++;
    }
    results.add(isCorrect);

    answerController.clear();

    if (currentIndex + 1 >= widget.cards.length) {
      // Сохраняем результаты перед переходом
      saveTestResult();
      // Переходим на экран с результатами
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultScreen(
            correctCount: correctCount,
            total: widget.cards.length,
            results: results,
            // moduleName: widget.moduleName,
          ),
        ),
      );
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }

  Future<void> saveTestResult() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('test_history')
        .add({
      'moduleId': widget.moduleId,
      // 'moduleName': widget.moduleName,
      'timestamp': FieldValue.serverTimestamp(),
      'correct': correctCount,
      'total': widget.cards.length,
      // Можно добавить дополнительные данные (например, подробности ответов)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Заучивание')),
        body: Center(child: Text('В этом модуле нет карточек для тестирования')),
      );
    }

    final currentCard = widget.cards[currentIndex];

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Заучивание')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Вопрос ${currentIndex + 1} из ${widget.cards.length}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              currentCard.term,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введите определение',
              ),
              onSubmitted: (_) => checkAnswer(),
              autofocus: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Ответить'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}