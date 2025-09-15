//19.05
import 'package:cloud_firestore/cloud_firestore.dart';
// Модель карточки
class CardModel {
  final String term;
  final String definition;

  // final String userId;      // ID пользователя (владелец карточки)
  // // final String moduleId;    // ID модуля, к которому принадлежит карточка
  
  // final String id;
  // final int box;
  // final DateTime? lastReviewed;
  // final DateTime? nextReview;

  CardModel({
    required this.term, 
    required this.definition, 
    // required this.userId,
    // required this.moduleId,
    // required this.id,
    // this.box = 1,
    // this.lastReviewed,
    // this.nextReview,
    });
    factory CardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CardModel(
      // id: doc.id,
      term: data['term'] ?? '',
      definition: data['definition'] ?? '',
      // box: data['box'] ?? 1,
      // lastReviewed: data['lastReviewed'] != null ? (data['lastReviewed'] as Timestamp).toDate() : null,
      // nextReview: data['nextReview'] != null ? (data['nextReview'] as Timestamp).toDate() : null,
    );
  }
}

// class CardModel {
//   final String id;          // ID документа в Firestore (опционально)
//   final String term;        // Термин карточки
//   final String definition;  // Определение карточки
//   final String userId;      // ID пользователя (владелец карточки)
//   final String moduleId;    // ID модуля, к которому принадлежит карточка
//   final Timestamp? createdAt; // Время создания (опционально)

//   CardModel({
//     required this.id,
//     required this.term,
//     required this.definition,
//     required this.userId,
//     required this.moduleId,
//     this.createdAt,
//   });

//   // Конструктор из документа Firestore
//   factory CardModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return CardModel(
//       id: doc.id,
//       term: data['term'] ?? '',
//       definition: data['definition'] ?? '',
//       userId: data['userId'] ?? '',
//       moduleId: data['moduleId'] ?? '',
//       createdAt: data['createdAt'],
//     );
//   }

//   // Конвертация в Map для сохранения в Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'term': term,
//       'definition': definition,
//       'userId': userId,
//       'moduleId': moduleId,
//       'createdAt': createdAt ?? FieldValue.serverTimestamp(),
//     };
//   }
// }