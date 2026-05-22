import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userCardsList.dart';

import 'package:coursework/services/test_service.dart';


import 'dart:math';
import 'leitner_test_tesult_screen.dart';
import 'module_progress_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class TestScreen extends StatefulWidget {
  final String moduleId;
  final List<CardModel> cards;
  final String moduleName;

  const TestScreen({
    Key? key,
    required this.moduleId,
    required this.cards,
    required this.moduleName,
  }) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TestService _testService = TestService();
  
  late List<CardModel> remainingCards;
  CardModel? currentCard;
  TextEditingController answerController = TextEditingController();
  int? selectedAnswerIndex;
  int correctCount = 0;
  int totalAttempts = 0;
  List<bool> sessionResults = [];
  
  bool showCorrectFeedback = false;

  @override
  void initState() {
    super.initState();
    remainingCards = List<CardModel>.from(widget.cards);
    _showNextCard();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void _showNextCard() {
    if (remainingCards.isEmpty) {
      _finishTest();
      return;
    }

    final random = Random();
    final randomIndex = random.nextInt(remainingCards.length);
    currentCard = remainingCards[randomIndex];
    
    setState(() {
      selectedAnswerIndex = null;
      
      showCorrectFeedback = false;
      answerController.clear();
    });
  }

  Future<void> _updateCard(CardModel card, bool isCorrect) async {
    await _testService.updateCard(
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      moduleId: widget.moduleId,
      cardId: card.id,
      currentBox: card.box,
      isCorrect: isCorrect,
    );
  }

    void _checkAnswer(String userAnswer) async {
      final trimmedAnswer = userAnswer.trim().toLowerCase();
      final correctTerm = currentCard!.term.trim().toLowerCase();
      final isCorrect = trimmedAnswer == correctTerm;

      if (selectedAnswerIndex != null && selectedAnswerIndex! == -1) {
        // Режим переписывания - переходим только если правильно
        if (isCorrect) {
          totalAttempts++;
          sessionResults.add(false); // переписывание не засчитывается
          setState(() {
            showCorrectFeedback = true;
          });
          await Future.delayed(Duration(milliseconds: 500));
          _showNextCard();
        }
        return;
      }

    // Первая проверка
    totalAttempts++;
    sessionResults.add(isCorrect);
    
    if (isCorrect) {
      correctCount++;
      await _updateCard(currentCard!, true);
      
      setState(() {
        showCorrectFeedback = true;
      });

      await Future.delayed(Duration(seconds: 1));
      remainingCards.removeWhere((card) => card.id == currentCard!.id);
      _showNextCard();
    } else {
      await _updateCard(currentCard!, false);
      setState(() {
        selectedAnswerIndex = -1; // Показать режим переписывания
        
        showCorrectFeedback = false;
      });
      answerController.clear();
    }
  }

  void _finishTest() async{
    await _testService.finishTest(
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      moduleId: widget.moduleId,
      moduleName: 'Заучивание',
      correctCount: correctCount,
      totalAttempts: totalAttempts,
      uniqueCards: widget.cards.length,
      remainingCards: remainingCards.length,
      readinessLevel: _calculateReadiness(),
    );
    await ModuleProgressService.updateModuleStats(widget.moduleId);

    final readinessLevel = _calculateReadiness();
    final leitnerRecommendation = _getLeitnerRecommendation();
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
          moduleName: 'Заучивание',  
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
      appBar: AppBar(title: Text('Заучивание')),
      body: Center(child: Text('Нет карточек для тестирования')),
    );
  }

  if (currentCard == null) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  final hasImage = currentCard!.imageUrl.isNotEmpty && currentCard!.imageUrl != '';
  final isShowingCorrectAnswer = selectedAnswerIndex != null && selectedAnswerIndex! == -1;
  final userAnswerCorrect = answerController.text.trim().toLowerCase() == currentCard!.term.trim().toLowerCase();

  return Scaffold(
    
    appBar: AppBar(
      // title: Text('Заучивание'),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(30),
        child: LinearProgressIndicator(
          value: widget.cards.isNotEmpty 
              ? (widget.cards.length - remainingCards.length) / widget.cards.length 
              : 0,
        ),
      ),
    ),
    body: Column( 
      children: [
        
        Expanded(
          flex: 7, 
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Осталось: ${remainingCards.length}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          Text(
            currentCard!.definition,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          if (hasImage) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentCard!.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) => child,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],

          // SizedBox(height: 20),

          Text(
            isShowingCorrectAnswer 
                ? 'Перепишите правильный ответ:' 
                : '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
        ],
      ),
            
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: answerController,
                  autofocus: true,
                  // textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: isShowingCorrectAnswer 
                        ? '${currentCard!.term}'  
                        : 'Введите термин...',
                    hintStyle: TextStyle(fontSize: 16),
                    // border: InputBorder.none,
                    // contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    suffixIcon: showCorrectFeedback
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  onChanged: (value) {
                    // Проверяем в реальном времени при показе правильного ответа
                    if (isShowingCorrectAnswer && value.trim().toLowerCase() == currentCard!.term.trim().toLowerCase()) {
                      // Правильно написал - можно переходить
                      setState(() {});
                    }
                  },
                  // onSubmitted: (_) => _checkAnswer(answerController.text), // При нажатии Enter/Готово на клавиатуре
                  ),
                // SizedBox(height: 2),
                // const SizedBox(height: 8),
                //   AnimatedSwitcher(
                //     duration: const Duration(milliseconds: 200),
                //     child: showCorrectFeedback
                //         ? const Row(
                //             key: ValueKey('correct'),
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Icon(Icons.check_circle, color: Colors.green, size: 22),
                //               SizedBox(width: 6),
                //               Text(
                //                 'Правильно!',
                //                 style: TextStyle(
                //                   color: Colors.green,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ],
                //           )
                //         : const SizedBox.shrink(key: ValueKey('empty')),
                //   ),
                if (!isShowingCorrectAnswer || userAnswerCorrect) ...[
                  
                  Align(
                  alignment: Alignment.centerRight,  
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),  // Компактные отступы
                      foregroundColor: Theme.of(context).colorScheme.primary,  // Цвет темы
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1,  // Компактная высота
                      ),
                    ),
                    onPressed: () => _checkAnswer(answerController.text),
                    child: Text(
                      isShowingCorrectAnswer ? 'Продолжить' : 'Проверить',
                    ),
                  ),
                ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}