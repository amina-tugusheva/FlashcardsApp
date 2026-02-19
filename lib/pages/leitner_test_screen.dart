import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userCardsList.dart';
import 'leitner_test_tesult_screen.dart';
import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

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
  late List<CardModel> remainingCards;  // Оставшиеся карточки в колоде
  CardModel? currentCard;
  List<String> shuffledChoices = [];
  int? selectedAnswerIndex;
  int correctCount = 0;
  int totalAttempts = 0;
  List<bool> sessionResults = [];

  @override
  void initState() {
    super.initState();
    remainingCards = List<CardModel>.from(widget.cards);
    _showNextCard();
  }

  void _showNextCard() {
    if (remainingCards.isEmpty) {
      _finishTest();
      return;
    }

    // Случайно выбираем карточку из оставшихся
    final random = Random();
    final randomIndex = random.nextInt(remainingCards.length);
    currentCard = remainingCards[randomIndex];
    
    _prepareChoices();
    setState(() {
      selectedAnswerIndex = null;
    });
  }

  void _prepareChoices() {
  if (currentCard == null) return;

  // используем ВСЮ исходную колоду widget.cards
  final allOtherCards = widget.cards
      .where((card) => card.id != currentCard!.id)
      .toList();
  
  allOtherCards.shuffle(Random());
  
  // Берем 3 случайных неправильных ответа ИЗ ВСЕЙ КОЛОДЫ
  final wrongAnswers = allOtherCards.take(3).map((c) => c.definition).toList();
  
  while (wrongAnswers.length < 3) {
    wrongAnswers.addAll(allOtherCards.take(3 - wrongAnswers.length)
        .map((c) => c.definition));
  }

  // Создаем полный список: 1 правильный + 3 неправильных из всей колоды
  List<String> choices = [currentCard!.definition, ...wrongAnswers];
  choices.shuffle(Random());
  
  shuffledChoices = choices;
}

  Future<void> _updateCard(CardModel card, bool isCorrect) async {
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
      newBox = min(card.box + 1, 5);
    } else {
      newBox = max(card.box - 1, 1);
    }

    // Интервалы повторения Лейтнера (дни)
    final Map<int, int> intervals = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    final now = DateTime.now();
    final nextReviewDate = now.add(Duration(days: intervals[newBox]!));

    await cardRef.update({
      'box': newBox,
      'lastReviewed': FieldValue.serverTimestamp(),
      'nextReview': Timestamp.fromDate(nextReviewDate),
      'sessionAttempts': FieldValue.increment(1), // Счетчик попыток в сеансе
    });
  }

  void _onAnswerSelected(int selectedIndex) async {
    if (selectedAnswerIndex != null) return;

    setState(() {
      selectedAnswerIndex = selectedIndex;
    });

    totalAttempts++;
    final isCorrect = shuffledChoices[selectedIndex] == currentCard!.definition;
    sessionResults.add(isCorrect);

    if (isCorrect) {
      correctCount++;
    }

    // Обновляем карточку в Firestore
    await _updateCard(currentCard!, isCorrect);

    // Показываем результат 1 секунду
    await Future.delayed(Duration(seconds: 1));

    if (isCorrect) {
      // Правильно → убираем из колоды
      remainingCards.removeWhere((card) => card.id == currentCard!.id);
    }
    // Неправильно → оставляем в колоде для повторного показа

    _showNextCard();
  }

  void _finishTest() {
    final readinessLevel = _calculateReadiness();
    final leitnerRecommendation = _getLeitnerRecommendation();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LeitnerTestResultScreen(
          correctCount: correctCount,
          totalAttempts: totalAttempts,
          uniqueCards: widget.cards.length,
          remainingCards: remainingCards.length,
          readinessLevel: readinessLevel,
          leitnerRecommendation: leitnerRecommendation,
          moduleName: widget.moduleName,
        ),
      ),
    );
  }

  String _calculateReadiness() {
    final successRate = totalAttempts > 0 ? correctCount / totalAttempts : 0;
    
    if (successRate >= 0.9) return 'Отлично! 🏆';
    if (successRate >= 0.8) return 'Хорошо! 👍';
    if (successRate >= 0.6) return 'Удовлетворительно 😊';
    return 'Нужно повторить 😕';
  }

  String _getLeitnerRecommendation() {
    final avgBox = widget.cards.isNotEmpty 
        ? widget.cards.map((c) => c.box).reduce((a, b) => a + b) / widget.cards.length
        : 0;
    
    if (avgBox >= 4.5) return 'Повторите через 14-30 дней';
    if (avgBox >= 3.5) return 'Повторите через 7-14 дней';
    if (avgBox >= 2.5) return 'Повторите через 3-7 дней';
    return 'Повторите завтра';
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
      'totalAttempts': totalAttempts,
      'uniqueCards': widget.cards.length,
      'remainingCards': remainingCards.length,
      'readinessLevel': _calculateReadiness(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Тест: ${widget.moduleName}')),
        body: Center(child: Text('Нет карточек для тестирования')),
      );
    }

    if (currentCard == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Тест: ${widget.moduleName}'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                // Text(
                //   'Правильно: $correctCount / ${widget.cards.length - remainingCards.length}',
                //   style: TextStyle(fontSize: 12),
                // ),
                LinearProgressIndicator(
                  value: widget.cards.isNotEmpty 
                      ? (widget.cards.length - remainingCards.length) / widget.cards.length 
                      : 0,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Осталось карточек: ${remainingCards.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            Text(
              currentCard!.term,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            Expanded(
              child: ListView.separated(
                itemCount: shuffledChoices.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  Color? cardColor;
                  IconData? icon;

                  if (selectedAnswerIndex != null) {
                    final isSelected = index == selectedAnswerIndex;
                    final isCorrectAnswer = shuffledChoices[index] == currentCard!.definition;

                    if (isSelected && isCorrectAnswer) {
                      cardColor = Colors.green[100];
                      icon = Icons.check_circle;
                    } else if (isSelected && !isCorrectAnswer) {
                      cardColor = Colors.red[100];
                      icon = Icons.close;
                    } else if (!isSelected && isCorrectAnswer) {
                      cardColor = Colors.green[50];
                      icon = Icons.check_circle_outline;
                    }
                  }

                  return Card(
                    color: cardColor,
                    elevation: selectedAnswerIndex != null ? 4 : 2,
                    child: ListTile(
                      leading: icon != null 
                          ? Icon(icon, color: Theme.of(context).primaryColor, size: 28)
                          : null,
                      title: Text(
                        shuffledChoices[index],
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: selectedAnswerIndex == null
                          ? () => _onAnswerSelected(index)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
