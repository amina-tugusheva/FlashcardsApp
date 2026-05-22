import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userCardsList.dart';
import 'leitner_test_tesult_screen.dart';
import 'dart:math';
import 'module_progress_service.dart';
import 'package:coursework/services/test_service.dart';

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
  final TestService _leitnerTestService = TestService();

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

  // используем ВСЮ исходную колоду 
  final allOtherCards = widget.cards.where((card) => card.id != currentCard!.id).toList();
  allOtherCards.shuffle(Random());
  
  final wrongTerms = allOtherCards.take(3).map((c) => c.term).toList();
    
    while (wrongTerms.length < 3) {
      wrongTerms.addAll(allOtherCards.take(3 - wrongTerms.length)
          .map((c) => c.term));
    }

    // List<String> choices = [currentCard!.term, ...wrongTerms];
    final choices = [currentCard!.term, ...wrongTerms];
    
    choices.shuffle(Random());
    
    shuffledChoices = choices;
}

  Future<void> _updateCard(CardModel card, bool isCorrect) async {
    await _leitnerTestService.updateCard(
      ownerId: FirebaseAuth.instance.currentUser!.uid,
  
      moduleId: widget.moduleId,
      cardId: card.id,
      currentBox: card.box,
      isCorrect: isCorrect,
    );
  }

  void _onAnswerSelected(int selectedIndex) async {
    if (selectedAnswerIndex != null) return;

    setState(() {
      selectedAnswerIndex = selectedIndex;
    });

    totalAttempts++;
    final isCorrect = shuffledChoices[selectedIndex] == currentCard!.term;
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

  void _finishTest() async {
    await _leitnerTestService.incrementSession(moduleId: widget.moduleId);

    final readinessLevel = _calculateReadiness();
    final leitnerRecommendation = _getLeitnerRecommendation();

    await _leitnerTestService.saveTestHistory(
      moduleId: widget.moduleId,
      moduleName: widget.moduleName,
      correctCount: correctCount,
      totalAttempts: totalAttempts,
      uniqueCards: widget.cards.length,
      remainingCards: remainingCards.length,
      readinessLevel: readinessLevel,
    );
    await ModuleProgressService.updateModuleStats(widget.moduleId);

    if (!mounted) return;

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
          moduleId: widget.moduleId,
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

    final hasImage = currentCard!.imageUrl.isNotEmpty && currentCard!.imageUrl != '';

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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Осталось карточек: ${remainingCards.length}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            Text(
              currentCard!.definition,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                // color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            if (hasImage) ...[
              Container(
              height: 120,  
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  currentCard!.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            ),
            ],

            
            
            SizedBox(height: 28),

            Expanded(
              child: ListView.separated(
                itemCount: shuffledChoices.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  Color? cardColor;
                  IconData? icon;

                  if (selectedAnswerIndex != null) {
                    final isSelected = index == selectedAnswerIndex;
                    final isCorrectAnswer = shuffledChoices[index] == currentCard!.term;

                    if (isSelected && isCorrectAnswer) {
                      cardColor = const Color.fromARGB(200, 70, 200, 90);
                      icon = Icons.check_circle;
                    } else if (isSelected && !isCorrectAnswer) {
                      cardColor = const Color.fromARGB(200, 255, 60, 50);
                      icon = Icons.close;
                    } else if (!isSelected && isCorrectAnswer) {
                      cardColor = const Color.fromARGB(200, 70, 200, 90);
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
