import 'package:flutter/material.dart';
import 'userCardsList.dart';
// import 'package:coursework/components/card_model.dart';

//import 'package:coursework/components/card_model.dart';
// Виджет для отображения одной карточки
class FlashCardWidget extends StatefulWidget {
  final CardModel card;

  const FlashCardWidget({Key? key, required this.card}) : super(key: key);

  @override
  _FlashCardWidgetState createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  bool showDefinition = false;

  void toggleCard() {
    setState(() {
      showDefinition = !showDefinition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleCard, // переключение отображения по тапу
      child: Card(
        margin: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          height: 300,
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text(
            showDefinition ? widget.card.definition : widget.card.term,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// Экран обучения с флэш-карточками
class FlashCardsScreen extends StatefulWidget {
  final List<CardModel> cards;

  const FlashCardsScreen({Key? key, required this.cards}) : super(key: key);

  @override
  _FlashCardsScreenState createState() => _FlashCardsScreenState();
}

class _FlashCardsScreenState extends State<FlashCardsScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void onNextCard() {
    if (currentIndex < widget.cards.length - 1) {
      currentIndex++;
      _pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {}); // для обновления индикатора или других элементов
    }
  }

  void onPrevCard() {
    if (currentIndex > 0) {
      currentIndex--;
      _pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Обучение")),
        body: Center(child: Text("Нет карточек для обучения")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Обучение")),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.cards.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return FlashCardWidget(card: widget.cards[index]);
              },
            ),
          ),

          // Индикатор текущей карточки
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Карточка ${currentIndex + 1} из ${widget.cards.length}",
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Кнопки навигации
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0 ? onPrevCard : null,
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 24),
                ElevatedButton(
                  onPressed: currentIndex < widget.cards.length - 1 ? onNextCard : null,
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}