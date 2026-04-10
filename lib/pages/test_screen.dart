import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'userCardsList.dart';
import 'test_result_screen.dart';
import 'createModuleScreen.dart'; 
import 'moduleListPage.dart';
import 'createCardScreen.dart';


import 'package:coursework/components/module_model.dart'; // import ModuleModel


// class TestScreen extends StatefulWidget {
//   final String moduleId;
//   // final String moduleName;
//   final List<CardModel> cards;

//   const TestScreen({
//     Key? key,
//     required this.moduleId,
//     // required this.moduleName,
//     required this.cards,
//   }) : super(key: key);

//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   int currentIndex = 0;
//   int correctCount = 0;
//   List<bool> results = [];
//   TextEditingController answerController = TextEditingController();
  
//   @override
//   void dispose() {
//     answerController.dispose();
//     super.dispose();
//   }

//   void checkAnswer() {
//     final card = widget.cards[currentIndex];
//     final userAnswer = answerController.text.trim().toLowerCase();
//     final correctAnswer = card.definition.trim().toLowerCase();

//     bool isCorrect = userAnswer == correctAnswer;

//     if (isCorrect) {
//       correctCount++;
//     }
//     results.add(isCorrect);

//     answerController.clear();

//     if (currentIndex + 1 >= widget.cards.length) {
//       // Сохраняем результаты перед переходом
//       saveTestResult();
//       // Переходим на экран с результатами
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TestResultScreen(
//             correctCount: correctCount,
//             total: widget.cards.length,
//             results: results,
//             // moduleName: widget.moduleName,
//           ),
//         ),
//       );
//     } else {
//       setState(() {
//         currentIndex++;
//       });
//     }
//   }

//   Future<void> saveTestResult() async {
//     final currentUser = FirebaseAuth.instance.currentUser!;
//     await FirebaseFirestore.instance
//         .collection('Users')
//         .doc(currentUser.uid)
//         .collection('test_history')
//         .add({
//       'moduleId': widget.moduleId,
//       // 'moduleName': widget.moduleName,
//       'timestamp': FieldValue.serverTimestamp(),
//       'correct': correctCount,
//       'total': widget.cards.length,
//       // Можно добавить дополнительные данные (например, подробности ответов)
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.cards.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Заучивание')),
//         body: Center(child: Text('В этом модуле нет карточек для тестирования')),
//       );
//     }

//     final currentCard = widget.cards[currentIndex];

//     return Scaffold(
//       appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text('Заучивание')),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Вопрос ${currentIndex + 1} из ${widget.cards.length}',
//               style: TextStyle(fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             Text(
//               currentCard.term,
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: answerController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Введите определение',
//               ),
//               onSubmitted: (_) => checkAnswer(),
//               autofocus: true,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: checkAnswer,
//               child: Text('Ответить'),
//               style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// test_screen.dart - Полностью переработанный с логикой Лейтнера

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
  late List<CardModel> remainingCards;
  CardModel? currentCard;
  TextEditingController answerController = TextEditingController();
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
      answerController.clear();
    });
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

    // int newBox;
    // if (isCorrect) {
    //   newBox = min(card.box + 1, 5);
    // } else {
    //   newBox = max(card.box - 1, 1);
    // }

    // final Map<int, int> intervals = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    // final now = DateTime.now();
    // final nextReviewDate = now.add(Duration(days: intervals[newBox]!));
    int newBox = isCorrect 
        ? (card.box + 1).clamp(1, 5)
        : (card.box - 1).clamp(1, 5);

    final intervals = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    final now = DateTime.now();
    final nextReviewDate = now.add(Duration(days: intervals[newBox]!));

    await cardRef.update({
      'box': newBox,
      'lastReviewed': FieldValue.serverTimestamp(),
      'nextReview': Timestamp.fromDate(nextReviewDate),
      'sessionAttempts': FieldValue.increment(1),
    });
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
      await Future.delayed(Duration(seconds: 1));
      remainingCards.removeWhere((card) => card.id == currentCard!.id);
      _showNextCard();
    } else {
      await _updateCard(currentCard!, false);
      setState(() {
        selectedAnswerIndex = -1; // Показать режим переписывания
      });
      answerController.clear();
    }
  }

  void _finishTest() async{
    // +1 сессия TestScreen!
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('modules')
        .doc(widget.moduleId)
        .update({'testSessions': FieldValue.increment(1)});
    
    // Обновляем общую статистику
    await ModuleProgressService.updateModuleStats(widget.moduleId);

    final readinessLevel = _calculateReadiness();
    final leitnerRecommendation = _getLeitnerRecommendation();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LeitnerTestResultScreen(  // та же как в первом режиме
          correctCount: correctCount,
          totalAttempts: totalAttempts,
          uniqueCards: widget.cards.length,
          remainingCards: remainingCards.length,
          readinessLevel: readinessLevel,
          leitnerRecommendation: leitnerRecommendation,
          moduleName: 'Заучивание',  // Можно передать из конструктора
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
      title: Text('Заучивание'),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(30),
        child: LinearProgressIndicator(
          value: widget.cards.isNotEmpty 
              ? (widget.cards.length - remainingCards.length) / widget.cards.length 
              : 0,
        ),
      ),
    ),
    body: Column(  // 🔥 Главный Column
      children: [
        
        Expanded(
          flex: 7,  // 70% высоты скроллится 
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Счетчик
          Text(
            'Осталось: ${remainingCards.length}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // ОПРЕДЕЛЕНИЕ 
          Text(
            currentCard!.definition,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // КАРТИНКА (если есть)
          // if (hasImage) ...[
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
          // ],

          // SizedBox(height: 20),

          // Заголовок задачи
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

          
          // Индикатор правильности (только при переписывании)
          // if (isShowingCorrectAnswer && answerController.text.isNotEmpty) ...[
          //   SizedBox(height: 16),
          //   AnimatedContainer(
          //     duration: Duration(milliseconds: 300),
          //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          //     decoration: BoxDecoration(
          //       color: userAnswerCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(
          //         color: userAnswerCorrect ? Colors.green : Colors.red,
          //         width: 1.5,
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           userAnswerCorrect ? Icons.check_circle : Icons.error,
          //           color: userAnswerCorrect ? Colors.green : Colors.red,
          //           size: 20,
          //         ),
          //         SizedBox(width: 8),
          //         Text(
          //           userAnswerCorrect 
          //               ? 'Отлично!' 
          //               : 'Попробуйте еще раз',
          //           style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.w500,
          //             color: userAnswerCorrect ? Colors.green[700] : Colors.red[700],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
        ],
      ),
            
          ),
        ),
        Expanded(
          flex: 3,
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
                // Кнопка только если ответ правильный или обычный режим
                if (!isShowingCorrectAnswer || userAnswerCorrect) ...[
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       padding: EdgeInsets.symmetric(vertical: 16),
                  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //     ),
                  //     onPressed: () => _checkAnswer(answerController.text),
                  //     child: Text(
                  //       isShowingCorrectAnswer ? 'Продолжить' : 'Проверить',
                  //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  //     ),
                  //   ),
                  // ),
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
        

          // 

          

      ],
    ),
  );
}

}