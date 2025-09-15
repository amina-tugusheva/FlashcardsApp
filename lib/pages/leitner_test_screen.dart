import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userCardsList.dart';
import 'leitner_test_tesult_screen.dart';
class LeitnerTestScreen extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final List<CardModel> cards;

  const LeitnerTestScreen({
    Key? key,
    required this.moduleId,
    required this.moduleName,
    required this.cards,
  }) : super(key: key);

  @override
  _LeitnerTestScreenState createState() => _LeitnerTestScreenState();
}

class _LeitnerTestScreenState extends State<LeitnerTestScreen> {
  int currentIndex = 0;
  int correctCount = 0;
  List<bool> results = [];

  // Используем контрол для выбора ответа
  int? selectedAnswerIndex;

  late List<String> shuffledChoices; // Варианты ответов для текущего вопроса

  @override
  void initState() {
    super.initState();
    _prepareChoices();
  }

  void _prepareChoices() {
    if (widget.cards.isEmpty) return;

    final currentCard = widget.cards[currentIndex];
    // Собираем неправильные варианты ответов из других карточек
    List<String> otherDefinitions = widget.cards
        .where((c) => c.id != currentCard.id)
        .map((c) => c.definition)
        .toList();

    otherDefinitions.shuffle();

    // Добавляем правильный ответ и перемешиваем варианты
    List<String> choices = [currentCard.definition];
    choices.addAll(otherDefinitions.take(3)); // 3 неправильных варианта

    choices.shuffle();

    shuffledChoices = choices;
    selectedAnswerIndex = null;
  }

  Future<void> _updateCardAfterAnswer(CardModel card, bool isCorrect) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final cardRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('modules')
        .doc(widget.moduleId)
        .collection('user_cards')
        .doc(card.id);

    int newBox;
    if (isCorrect) {
      newBox = (card.box < 5) ? card.box + 1 : 5;
    } else {
      newBox = 1; // или можно реализовать уменьшение на 1, если хотите
    }

    final intervals = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    final now = DateTime.now();
    final nextReviewDate = now.add(Duration(days: intervals[newBox]!));

    await cardRef.update({
      'box': newBox,
      'lastReviewed': Timestamp.fromDate(now),
      'nextReview': Timestamp.fromDate(nextReviewDate),
    });
  }

  void _onAnswerSelected(int selectedIndex) async {
    if (selectedAnswerIndex != null) return; // уже выбран ответ

    setState(() {
      selectedAnswerIndex = selectedIndex;
    });

    final currentCard = widget.cards[currentIndex];
    final selectedAnswer = shuffledChoices[selectedIndex];
    final isCorrect = selectedAnswer == currentCard.definition;

    if (isCorrect) {
      correctCount++;
    }
    results.add(isCorrect);

    // Обновляем карточку в Firestore согласно Лейтнеру
    await _updateCardAfterAnswer(currentCard, isCorrect);

    // Ждём 1 секунду, чтобы пользователь увидел результат
    await Future.delayed(Duration(seconds: 1));

    if (currentIndex + 1 >= widget.cards.length) {
      // Сохраняем результат теста
      await _saveTestResult();

      // Переходим на экран результатов
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LeitnerTestTesultScreen(
            correctCount: correctCount,
            total: widget.cards.length,
            results: results,
            moduleName: widget.moduleName,
          ),
        ),
      );
    } else {
      setState(() {
        currentIndex++;
        selectedAnswerIndex = null;
      });
      _prepareChoices();
    }
  }

  Future<void> _saveTestResult() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('test_history')
        .add({
      'moduleId': widget.moduleId,
      'moduleName': widget.moduleName,
      'timestamp': FieldValue.serverTimestamp(),
      'correct': correctCount,
      'total': widget.cards.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Тест: ${widget.moduleName}')),
        body: Center(child: Text('В этом модуле нет карточек для тестирования')),
      );
    }

    final currentCard = widget.cards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Тест: ${widget.moduleName}')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Вопрос ${currentIndex + 1} из ${widget.cards.length}',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            SizedBox(height: 30),
            Text(
              currentCard.term,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Варианты ответов
            ...List.generate(shuffledChoices.length, (index) {
              Color? color;
              if (selectedAnswerIndex != null) {
                if (index == selectedAnswerIndex) {
                  color = shuffledChoices[index] == currentCard.definition ? Colors.greenAccent[400] : Colors.redAccent[400];
                } else if (shuffledChoices[index] == currentCard.definition) {
                  color = Colors.greenAccent[400];
                }
              }
              return Card(
                color: color,
                child: ListTile(
                  title: Text(shuffledChoices[index]),
                  onTap: () => _onAnswerSelected(index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
