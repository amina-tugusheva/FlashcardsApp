import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/pages/userCardsList.dart';

import 'package:firebase_auth/firebase_auth.dart';

class CardsService {
  final FirebaseFirestore _firestore;

  CardsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> loadPopularModules() async {
    final snapshot = await _firestore
        .collectionGroup('modules')
        .where('isPublic', isEqualTo: true)
        .orderBy('savesCount', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Без названия',
        'savesCount': data['savesCount'] ?? 0,
        'cardsCount': data['cardsCount'] ?? 0,
        'description': data['description']?.toString() ?? '',
        'userId': doc.reference.parent.parent?.id ?? '',
      };
    }).toList();
  }

  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _cardsCollection({
    required String userId,
    required String moduleId,
  }) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId)
        .collection('user_cards');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCardsStream({
    String? authorId,
    required String moduleId,
  }) {
    final userIdToQuery = authorId ?? _currentUserId;
    return _cardsCollection(userId: userIdToQuery, moduleId: moduleId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<CardModel>> getCards({
    String? authorId,
    required String moduleId,
  }) async {
    final snapshot = await getCardsStream(
      authorId: authorId,
      moduleId: moduleId,
    ).first;

    return snapshot.docs.map(CardModel.fromDocument).toList();
  }

  Future<void> deleteMyModule({
    required String moduleId,
  }) async {
    await _firestore
        .collection('Users')
        .doc(_currentUserId)
        .collection('modules')
        .doc(moduleId)
        .delete();
  }

  Future<Map<String, dynamic>> getAuthorInfo(String? authorId) async {
    if (authorId == null) {
      return {'name': 'Неизвестный автор'};
    }

    final authorSnapshot = await _firestore.collection('Users').doc(authorId).get();
    if (!authorSnapshot.exists) return {'name': 'Неизвестный автор'};

    final data = authorSnapshot.data() ?? {};
    return {
      'name': data['имя пользователя'] ?? 'Без имени',
    };
  }

  Future<String> getModuleDescription({
    required String? authorId,
    required String moduleId,
  }) async {
    if (authorId == null) return 'Описание модуля недоступно';

    final moduleSnapshot = await _firestore
        .collection('Users')
        .doc(authorId)
        .collection('modules')
        .doc(moduleId)
        .get();

    if (!moduleSnapshot.exists) return 'Описание модуля недоступно';
    return moduleSnapshot.data()?['description'] ?? 'Нет описания';
  }

  Future<void> copyPublicModuleToMyModules({
    required String? authorId,
    required String moduleId,
    required String moduleName,
  }) async {
    final sourceUserId = authorId;
    if (sourceUserId == null) return;

    final cardsSnapshot = await _cardsCollection(
      userId: sourceUserId,
      moduleId: moduleId,
    ).get();

    if (cardsSnapshot.docs.isEmpty) {
      throw Exception('Карточек нет для копирования');
    }

    final cards = cardsSnapshot.docs.map(CardModel.fromDocument).toList();
    final newModuleRef = _firestore
        .collection('Users')
        .doc(_currentUserId)
        .collection('modules')
        .doc();

    final authorInfo = await getAuthorInfo(authorId);
    final moduleDescription = await getModuleDescription(
      authorId: authorId,
      moduleId: moduleId,
    );

    await newModuleRef.set({
      'name': moduleName,
      'description': moduleDescription,
      'isPublic': false,
      'cardsCount': cards.length,
      'createdAt': FieldValue.serverTimestamp(),
      'sourceModuleId': moduleId,
      'sourceAuthorId': authorId,
      'isSaved': true,
      'sourceAuthorName': authorInfo['name'],
      'savesCount': 0,
    });

    for (final card in cardsSnapshot.docs) {
      final data = card.data();
      await newModuleRef.collection('user_cards').add({
        'term': data['term'],
        'definition': data['definition'],
        'imageUrl': data['imageUrl'] ?? '',
        'box': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'sessionAttempts': 0,
      });
    }

    await _firestore
        .collection('Users')
        .doc(sourceUserId)
        .collection('modules')
        .doc(moduleId)
        .update({'savesCount': FieldValue.increment(1)});
  }
}