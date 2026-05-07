import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'flashCardsScreen.dart';
import 'test_screen.dart';
import 'moduleListPage.dart';
import 'create_module.dart';
import "leitner_test_screen.dart";

//import 'package:coursework/components/card_model.dart';
// Модель карточки
class CardModel {
  final String term;
  final String definition;

  // final String userId;      // ID пользователя (владелец карточки)
  // final String moduleId;    // ID модуля, к которому принадлежит карточка

  final String id;         // ID карточки из Firestore
  final int box;           // Уровень Лейтнера от 1 до 5
  final DateTime? nextReview;
  final String imageUrl;

  CardModel({
    required this.term, 
    required this.definition, 
    // required this.userId,
    // required this.moduleId,

    required this.id,
    required this.box,
    this.nextReview,
    required this.imageUrl,
    });

    factory CardModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CardModel(
      term: data['term'] ?? '',
      definition: data['definition'] ?? '',
      id: doc.id,
      box: data['box'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      nextReview: data['nextReview'] != null
          ? (data['nextReview'] as Timestamp).toDate()
          : null,
    );
  }
}
class UserCardsList extends StatefulWidget {
  final String moduleId, moduleName;

  final String? authorId; // ID автора (null = свои)
  final bool isPublicStudy; // Режим просмотра чужих

  const UserCardsList({
    super.key, 
    required this.moduleId, 
    required this.moduleName,
    this.authorId,
    this.isPublicStudy = false,
    });

  @override
  State<UserCardsList> createState() => _UserCardsListState();
}

class _UserCardsListState extends State<UserCardsList> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Универсальная функция получения карточек
  Stream<QuerySnapshot> getCardsStream() {
    String userIdToQuery = widget.authorId ?? currentUser.uid; // Свои или чужие
    
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userIdToQuery) // authorId или currentUser
        .collection('modules')
        .doc(widget.moduleId)
        .collection('user_cards')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  

  // Функция получения карточек
  Future<List<CardModel>> _getCards() async {
    // final snapshot = await FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(currentUser.uid)
    //     .collection('modules')
    //     .doc(widget.moduleId)
    //     .collection('user_cards')
    //     .get();
    final snapshot = await getCardsStream().first;
    return snapshot.docs.map(CardModel.fromDocument).toList();
  }
  Future<void> _goToFlashCards() async {
  final cards = await _getCards();
  if (cards.isEmpty || !mounted) return;
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => FlashCardsScreen(cards: cards),
  ));
  }

  Future<void> _goToTest() async {
    final cards = await _getCards();
    if (cards.isEmpty || !mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LeitnerTestScreen(
        moduleId: widget.moduleId,
        moduleName: widget.moduleName,
        cards: cards,
      ),
    ));
  }

  Future<void> _goToCheck() async {
    final cards = await _getCards();
    if (cards.isEmpty || !mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TestScreen(
        moduleId: widget.moduleId, 
        moduleName: widget.moduleName,
        cards: cards),
    ));
  }

  // Удаление модуля (Firestore автоочищает карточки)
  Future<void> _deleteModule() async {
    if (widget.isPublicStudy) return; // Нельзя удалять чужие!

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Удалить модуль?'),
        content: Text('${widget.moduleName} и все карточки будут удалены навсегда.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Отмена')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .doc(widget.moduleId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Модуль удален'), backgroundColor: Colors.red),
      );
      Navigator.pop(context); //  Возврат на moduleListPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }
  // функция сохранения модулей других пользовтелей 
  Future<void> _copyToMyModules() async {
    if (!widget.isPublicStudy) return; // Только для чужих!

    final cardsStream = getCardsStream();
    final snapshot = await cardsStream.first;
    final cards = snapshot.docs.map(CardModel.fromDocument).toList();
    
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Карточек нет для копирования')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser!;
  final newModuleRef = FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser.uid)
      .collection('modules')
      .doc();

  // ПРОФИЛЬ АВТОРА
  final authorSnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(widget.authorId)
      .get();

  String authorName = 'Неизвестный автор';
  if (authorSnapshot.exists) {
    authorName = authorSnapshot.data()!['имя пользователя'] ?? 'Без имени';
  }

  // ОПИСАНИЕ ИЗ МОДУЛЯ АВТОРА
  final moduleSnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(widget.authorId)
      .collection('modules')
      .doc(widget.moduleId)
      .get();

  String moduleDescription = 'Описание модуля недоступно';
  if (moduleSnapshot.exists) {
    moduleDescription = moduleSnapshot.data()?['description'] ?? 'Нет описания';
  }

  print('🔍 AUTHOR: $authorName');
  print('🔍 MODULE_DESC: $moduleDescription');

    // Метаданные модуля
    await newModuleRef.set({
      'name': widget.moduleName,
      'description': moduleDescription,  
      'isPublic': false,
      'cardsCount': cards.length,
      'createdAt': FieldValue.serverTimestamp(),
      'sourceModuleId': widget.moduleId,
      'sourceAuthorId': widget.authorId,
      'isSaved': true,
      'sourceAuthorName': authorName,
      'savesCount': 0,
    });

    // Копируем все карточки
    for (final cardDoc in snapshot.docs) {
      final cardData = cardDoc.data() as Map<String, dynamic>;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .doc(newModuleRef.id)
          .collection('user_cards')
          .add({
        'term': cardData['term'],
        'definition': cardData['definition'],
        'imageUrl': cardData['imageUrl'] ?? '',
        'box': 1, // Сброс Leitner
        'createdAt': FieldValue.serverTimestamp(),
        'sessionAttempts': 0,
      });
    }
     // УВЕЛИЧИВАЕМ ПОПУЛЯРНОСТЬ ОРИГИНАЛА
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.authorId) 
        .collection('modules')
        .doc(widget.moduleId) 
        .update({
      'savesCount': FieldValue.increment(1),  // +1 сохранение
    }).catchError((error) {
      print('Не удалось обновить savesCount: $error');
      // Не критично — продолжаем
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cards.length} карточек сохранено в Мои модули!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Открыть',
            onPressed: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModuleListPage(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _showModuleActionsSheet(BuildContext context) {
  
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isPublicStudy) ...[
              ListTile(
                leading: Icon(Icons.download, color: Colors.green),
                title: Text('Сохранить в Мои модули'),
                subtitle: Text('Полная копия для редактирования'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToMyModules();
                },
              ),
              Divider(),
            ],
            if (!widget.isPublicStudy) ...[
              ListTile(
                title: Text('Редактировать модуль', style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text('Изменить название, описание и карточки'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context); // Закрыть bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateModule(  
                        moduleId: widget.moduleId,
                        moduleName: widget.moduleName,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              // Разделитель
              Divider(height: 1, thickness: 1),
              SizedBox(height: 12),
              // Удалить модуль
              ListTile(
                title: Text('Удалить модуль', style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text('Удалит модуль и все карточки навсегда'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context); // Закрыть bottom sheet
                  _deleteModule();        // Удаление
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // Поток карточек для списка
    final cardsStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('modules')
        .doc(widget.moduleId)
        .collection('user_cards')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
        
        
      actions: [
        
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => _showModuleActionsSheet(context),
        ),
      ],

      ),

      body: Column(
        children: [
          // Блок с тремя кнопками
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Кнопка "Карточки"
                ElevatedButton(
                onPressed: _goToFlashCards, child: Text('Просмотр')),

                // Кнопка "Тестирование"
                ElevatedButton(
                  onPressed: _goToTest, child: Text('Тест')
                ),

                // Кнопка "Обучение"
                ElevatedButton(
                  onPressed: _goToCheck, child: Text('Проверка')
                ),
              ],
            ),
          ),
          // Список карточек
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // stream: cardsStream,
              stream: getCardsStream(), 
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки данных'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                //   return Center(child: Text('Карточек пока нет'));
                // }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.isPublicStudy ? Icons.lock : Icons.add, size: 64),
                        SizedBox(height: 16),
                        Text(widget.isPublicStudy 
                            ? 'Карточек нет' 
                            : 'Добавьте первую карточку'),
                      ],
                    ),
                  );
                }

                final cards = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final cardDoc = cards[index];
                    final cardData = cardDoc.data()! as Map<String, dynamic>;
                    final box = cardData['box'] ?? 1;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(cardData['term'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cardData['definition'] ?? ''),
                            SizedBox(height: 4),
                            Text(
                              'Уровень повторения: $box',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

