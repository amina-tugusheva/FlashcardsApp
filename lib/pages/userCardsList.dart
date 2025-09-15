import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'flashCardsScreen.dart';
import 'createCardScreen.dart';

import 'package:coursework/components/module_model.dart';
//import 'package:coursework/components/card_model.dart';
import 'test_screen.dart';
import 'createModuleScreen.dart'; 
import 'moduleListPage.dart';
import 'createCardScreen.dart';
import 'test_result_screen.dart';

// import 'package:coursework/components/card_model.dart';
import "leitner_test_screen.dart";
// Модель карточки
class CardModel {
  final String term;
  final String definition;

  // final String userId;      // ID пользователя (владелец карточки)
  // final String moduleId;    // ID модуля, к которому принадлежит карточка

  final String id;         // ID карточки из Firestore
  final int box;           // Уровень Лейтнера от 1 до 5
  final DateTime? nextReview;

  CardModel({
    required this.term, 
    required this.definition, 
    // required this.userId,
    // required this.moduleId,

    required this.id,
    required this.box,
    this.nextReview,
    });
}

class UserCardsList extends StatelessWidget {

  final String moduleId;
  final String moduleName; // Для отображения в AppBar

  final currentUser = FirebaseAuth.instance.currentUser!;

  UserCardsList({Key? key, 
  required this.moduleId,
  required this.moduleName

  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    // Поток карточек для списка
    final cardsStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('modules')
        .doc(moduleId)
        .collection('user_cards')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(moduleName),
      ),

      body: Column(
        children: [
          // Блок с тремя кнопками
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Кнопка "Карточки"
                ElevatedButton(
                      onPressed: () async {
                    // Получение карточек из Firestore для текущего пользователя
                    final snapshot = await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(currentUser.uid)
                        .collection('modules')
                        .doc(moduleId)                 
                        .collection('user_cards')
                        .get();

                    final cards = snapshot.docs.map((doc) {
                      final data = doc.data();
                      return CardModel(
                        term: data['term'] ?? '',
                        definition: data['definition'] ?? '',

                        id: doc.id,
                        box: data['box'] ?? 1,
                        nextReview: data['nextReview'] != null
                          ? (data['nextReview'] as Timestamp).toDate()
                          : null,
                        
                      );
                    }).toList();

                    if (cards.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Нет карточек для обучения')),
                      );
                      return;
                    }
                    // Переход на экран обучения, передаем список карточек
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashCardsScreen(cards: cards),
                      ),
                    );
                  },
                  child: Text('Карточки'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(100, 40)),
                ),

                // Кнопка "Тестирование"
                ElevatedButton(
                      onPressed: () async {
                    // Получение карточек из Firestore для текущего пользователя
                    final snapshot = await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(currentUser.uid)
                        .collection('modules')
                        .doc(moduleId)                 
                        .collection('user_cards')
                        .get();

                    final cards = snapshot.docs.map((doc) {
                      final data = doc.data();
                      return CardModel(
                        term: data['term'] ?? '',
                        definition: data['definition'] ?? '',

                        id: doc.id,
                        box: data['box'] ?? 1,
                        nextReview: data['nextReview'] != null
                          ? (data['nextReview'] as Timestamp).toDate()
                          : null,
                        
                      );
                    }).toList();

                    if (cards.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Нет карточек для обучения')),
                      );
                      return;
                    }
                    // Переход на экран обучения, передаем список карточек
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        
                        builder: (context) => LeitnerTestScreen(
                          moduleId: moduleId,
                          moduleName: moduleName,
                          cards: cards,
                        ),
                        
                      ),
                    );
                  },
                  child: Text('Тестирование'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(120, 40)),
                ),

                // Кнопка "Обучение"
                ElevatedButton(
                      onPressed: () async {
                        // Получение карточек из Firestore для текущего пользователя
                        final snapshot = await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(currentUser.uid)
                            .collection('modules')
                            .doc(moduleId)                 
                            .collection('user_cards')
                            .get();

                        final cards = snapshot.docs.map((doc) {
                          final data = doc.data();
                          return CardModel(
                            term: data['term'] ?? '',
                            definition: data['definition'] ?? '',

                            id: doc.id,
                            box: data['box'] ?? 1,
                            nextReview: data['nextReview'] != null
                              ? (data['nextReview'] as Timestamp).toDate()
                              : null,
                            
                          );
                        }).toList();

                        if (cards.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Нет карточек для обучения')),
                          );
                          return;
                        }
                        // Переход на экран обучения, передаем список карточек
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestScreen(cards: cards, 
                            // moduleName: moduleName, 
                            moduleId: moduleId
                            ),
                          ),
                        );
                      },
                  child: Text('Обучение'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(100, 40)),
                ),
              ],
            ),
          ),
          // Список карточек внизу, занимает остаток экрана
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cardsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки данных'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Карточек пока нет'));
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Редактировать карточку',
                              onPressed: () {
                                // Ваша логика редактирования карточки здесь
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              tooltip: 'Удалить карточку',
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Удалить карточку?'),
                                    content: Text(
                                        'Вы уверены, что хотите удалить эту карточку?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Отмена'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          'Удалить',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldDelete == true) {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(currentUser.uid)
                                      .collection('modules')
                                      .doc(moduleId)
                                      .collection('user_cards')
                                      .doc(cardDoc.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Карточка удалена')),
                                  );
                                }
                              },
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCardScreen(moduleId: moduleId),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Создать новую карточку',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.play_arrow),
        //     tooltip: 'Начать обучение',
        //     onPressed: () async {
        //       // Получение карточек из Firestore для текущего пользователя
        //       final snapshot = await FirebaseFirestore.instance
        //           .collection('Users')
        //           .doc(currentUser.uid)
        //           .collection('modules')
        //           .doc(moduleId)                 
        //           .collection('user_cards')
        //           .get();

        //       final cards = snapshot.docs.map((doc) {
        //         final data = doc.data();
        //         return CardModel(
        //           term: data['term'] ?? '',
        //           definition: data['definition'] ?? '',

        //           id: doc.id,
        //           box: data['box'] ?? 1,
        //           nextReview: data['nextReview'] != null
        //             ? (data['nextReview'] as Timestamp).toDate()
        //             : null,
                  
        //         );
        //       }).toList();

        //       if (cards.isEmpty) {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(content: Text('Нет карточек для обучения')),
        //         );
        //         return;
        //       }
        //       // удаление карточки 
              

        //       // Переход на экран обучения, передаем список карточек
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           // builder: (context) => FlashCardsScreen(cards: cards),
        //           // builder: (context) => LeitnerTestScreen(
        //           //   moduleId: moduleId,
        //           //   moduleName: moduleName,
        //           //   cards: cards,
        //           // ),
        //           builder: (context) => TestScreen(cards: cards, 
        //           // moduleName: moduleName, 
        //           moduleId: moduleId
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        //   // SizedBox(height: 16),

        //   // IconButton(
        //   //   icon: Icon(Icons.play_arrow),
        //   //   tooltip: 'Начать обучение',
        //   //   onPressed: () async {
        //   //     // Переход на экран со списком модулей пользователя
        //   //       Navigator.push(
        //   //         context,
        //   //         MaterialPageRoute(builder: (context) => TestScreen()),
        //   //       );
        //   //   },
        //   // ),
        // ],
//         Expanded(child: )
      
//       body: StreamBuilder<QuerySnapshot>(
        
//         stream: FirebaseFirestore.instance
//             .collection('Users')
//             .doc(currentUser.uid)
//             .collection('modules')
//             .doc(moduleId)
//             .collection('user_cards')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Ошибка загрузки данных'));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('Карточек пока нет'));
//           }

//           final cards = snapshot.data!.docs;

//           return ListView.builder(
//             // itemCount: cards.length,
//             // itemBuilder: (context, index) {
//             //   final cardData = cards[index].data()! as Map<String, dynamic>;
//             //   return Card(
//             //     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             //     child: ListTile(
//             //       title: Text(cardData['term'] ?? ''),
//             //       subtitle: Text(cardData['definition'] ?? ''),
//             //     ),
//             //   );
//             // },
//             itemCount: cards.length,
//             itemBuilder: (context, index) {
//               final cardDoc = cards[index]; // Это DocumentSnapshot
//               final cardData = cardDoc.data()! as Map<String, dynamic>;

//               final box = cardData['box'] ?? 1;

//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   title: Text(cardData['term'] ?? ''),
//                   // subtitle: 
//                   // Text(cardData['definition'] ?? ''),

//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(cardData['definition'] ?? ''),
//                       SizedBox(height: 4),
//                       Text('Уровень повторения: $box',
//                         style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
//                       ),
//                     ],
//                   ),

//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.blue),
//                         tooltip: 'Редактировать карточку',
//                         onPressed: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) => EditCardScreen(
//                           //       moduleId: moduleId,
//                           //       cardId: cardDoc.id,
//                           //       initialTerm: cardData['term'] ?? '',
//                           //       initialDefinition: cardData['definition'] ?? '',
//                           //     ),
//                           //   ),
//                           // );
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.delete, 
//                           // color: Colors.red
//                           ),
//                         tooltip: 'Удалить карточку',
//                         onPressed: () async {
//                           final shouldDelete = await showDialog<bool>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: Text('Удалить карточку?'),
//                               content: Text('Вы уверены, что хотите удалить эту карточку?'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, false),
//                                   child: Text('Отмена'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   child: Text('Удалить', style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (shouldDelete == true) {
//                             await FirebaseFirestore.instance
//                               .collection('Users')
//                               .doc(currentUser.uid)
//                               .collection('modules')
//                               .doc(moduleId)
//                               .collection('user_cards')
//                               .doc(cardDoc.id)
//                               .delete();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Карточка удалена')),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
          
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CreateCardScreen(moduleId: moduleId),
//             ),
//             // MaterialPageRoute(builder: (context) => CreateCardScreen()),
//           );
//         },
//         child: Icon(Icons.add), // знак "+"
//         tooltip: 'Создать новую карточку',
//       ),
//     floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // расположение справа внизу
    
//     // bottomNavigationBar: Padding(
//     //   padding: const EdgeInsets.all(16.0),
//     //   child: ElevatedButton(
//     //     onPressed: () async {
//     //       // Получаем все карточки модуля для теста
//     //       final snapshot = await FirebaseFirestore.instance
//     //         .collection('Users')
//     //         .doc(currentUser.uid)
//     //         .collection('modules')
//     //         .doc(moduleId)
//     //         .collection('user_cards')
//     //         .get();

//     //       final cards = snapshot.docs.map((doc) {
//     //         final data = doc.data();
//     //         return CardModel(
//     //           term: data['term'] ?? '',
//     //           definition: data['definition'] ?? '',
//     //         );
//     //       }).toList();

//     //       if (cards.isEmpty) {
//     //         ScaffoldMessenger.of(context).showSnackBar(
//     //           SnackBar(content: Text('В этом модуле нет карточек для теста')),
//     //         );
//     //         return;
//     //       }

//     //       // Переходим на экран тестирования и передаем карточки
//     //       Navigator.push(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (context) => TestScreen(cards: cards, 
//     //           // moduleName: moduleName, 
//     //           moduleId: moduleId
//     //           ),
//     //         ),
//     //       );
//     //     },
//     //     child: Text('Начать тестирование'),
//     //     style: ElevatedButton.styleFrom(
//     //       minimumSize: Size(double.infinity, 50), // кнопка на всю ширину и высоту 50
//     //       textStyle: TextStyle(fontSize: 18),
//     //     ),
//     //   ),
//     // ),
    
//     );
//   }
// }
