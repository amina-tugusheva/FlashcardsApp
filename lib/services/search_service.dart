import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore;

  SearchService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final snapshot = await _firestore
        .collection('Users')
        .where('имя пользователя',
            isGreaterThanOrEqualTo: q,
            isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['имя пользователя'] ?? 'Без имени').toString(),
        'email': (data['email'] ?? '').toString(),
        'avatarUrl': (data['avatarUrl'] ?? '').toString(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> searchModules(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final snapshot = await _firestore
        .collectionGroup('modules')
        .where('name', isGreaterThanOrEqualTo: q)
        .where('name', isLessThanOrEqualTo: '$q\uf8ff')
        .where('isPublic', isEqualTo: true)
        .orderBy('cardsCount', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['name'] ?? 'Без названия').toString(),
        'cardsCount': data['cardsCount'] ?? 0,
        'userId': doc.reference.parent.parent?.id ?? '',
        'description': (data['description'] ?? '').toString(),
      };
    }).toList();
  }
}