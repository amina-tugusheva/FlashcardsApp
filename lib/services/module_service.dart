import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/module_model.dart';

class ModuleService {
  final FirebaseFirestore _firestore;

  ModuleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _modulesRef(String userId) {
    return _firestore.collection('Users').doc(userId).collection('modules');
  }

  CollectionReference<Map<String, dynamic>> _cardsRef(String userId, String moduleId) {
    return _modulesRef(userId).doc(moduleId).collection('user_cards');
  }

  

  Future<Map<String, dynamic>?> loadModule(String userId, String moduleId) async {
    final moduleDoc = await _modulesRef(userId).doc(moduleId).get();

    if (!moduleDoc.exists) return null;

    final moduleData = moduleDoc.data() ?? {};

    final cardsSnapshot = await _cardsRef(userId, moduleId)
        .orderBy('createdAt')
        .get();

    final cards = cardsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'term': data['term']?.toString() ?? '',
        'definition': data['definition']?.toString() ?? '',
        'box': data['box'] ?? 1,
        'correct_count': data['correct_count'] ?? 0,
      };
    }).toList();

    return {
      'name': moduleData['name'] ?? '',
      'description': moduleData['description'] ?? '',
      'isPublic': moduleData['isPublic'] ?? true,
      'cards': cards,
    };
  }

  Future<void> createModule({
    required String userId,
    required String name,
    required String description,
    required bool isPublic,
    required List<Map<String, String>> cards,
  }) async {
    final moduleRef = await _modulesRef(userId).add({
      'name': name,
      'description': description.isEmpty ? null : description,
      'userId': userId,
      'isPublic': isPublic,
      'cardsCount': cards.length,
      'testSessions': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    final batch = _firestore.batch();

    for (final card in cards) {
      final cardRef = _cardsRef(userId, moduleRef.id).doc();
      batch.set(cardRef, {
        'term': card['term'],
        'definition': card['definition'],
        'userId': userId,
        'moduleId': moduleRef.id,
        'imageUrl': '',
        'box': 1,
        'correct_count': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> updateModule({
    required String userId,
    required String moduleId,
    required String name,
    required String description,
    required bool isPublic,
    required List<Map<String, String>> cards,
  }) async {
    final batch = _firestore.batch();
    final moduleDocRef = _modulesRef(userId).doc(moduleId);

    batch.update(moduleDocRef, {
      'name': name,
      'description': description.isEmpty ? null : description,
      'isPublic': isPublic,
      'cardsCount': cards.length,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    final oldCards = await _cardsRef(userId, moduleId).get();
    for (final doc in oldCards.docs) {
      batch.delete(doc.reference);
    }

    for (final card in cards) {
      final newCardRef = _cardsRef(userId, moduleId).doc();
      batch.set(newCardRef, {
        'term': card['term'],
        'definition': card['definition'],
        'userId': userId,
        'moduleId': moduleId,
        'imageUrl': '',
        'box': 1,
        'correct_count': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<List<ModuleModel>> watchUserModules(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('modules')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ModuleModel.fromFirestore(doc)).toList();
    });
  }

  List<ModuleModel> splitModules({
    required List<ModuleModel> modules,
    required bool showSavedOnly,
  }) {
    return modules.where((module) {
      final isSavedModule = module.isSaved ?? false;
      return showSavedOnly ? isSavedModule : !isSavedModule;
    }).toList();
  }
}