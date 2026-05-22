import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:coursework/components/module_model.dart';

class TestService {
  final FirebaseFirestore _firestore;

  TestService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> _moduleRef(String moduleId) {
    return _firestore
        .collection('Users')
        .doc(_userId)
        .collection('modules')
        .doc(moduleId);
  }

  DocumentReference<Map<String, dynamic>> _cardRef(String moduleId, String cardId) {
    return _moduleRef(moduleId).collection('user_cards').doc(cardId);
  }

  Future<void> updateCard({
    required String ownerId,
    required String moduleId,
    required String cardId,
    required int currentBox,
    required bool isCorrect,
  }) async {
    final newBox = isCorrect
        ? (currentBox + 1).clamp(1, 5)
        : (currentBox - 1).clamp(1, 5);

    final intervals = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    final nextReviewDate = DateTime.now().add(Duration(days: intervals[newBox]!));

    await _cardRef(moduleId, cardId).update({
      'box': newBox,
      'lastReviewed': FieldValue.serverTimestamp(),
      'nextReview': Timestamp.fromDate(nextReviewDate),
      'sessionAttempts': FieldValue.increment(1),
    });
  }

  Future<void> finishTest({
    
    required String ownerId,
    required String moduleId,
    required String moduleName,
    required int correctCount,
    required int totalAttempts,
    required int uniqueCards,
    required int remainingCards,
    required String readinessLevel,
  }) async {
    await _moduleRef(moduleId).update({
      'testSessions': FieldValue.increment(1),
    });

    await _firestore
        .collection('Users')
        .doc(_userId)
        .collection('test_history')
        .add({
      'moduleId': moduleId,
      'moduleName': moduleName,
      'timestamp': FieldValue.serverTimestamp(),
      'correct': correctCount,
      'totalAttempts': totalAttempts,
      'uniqueCards': uniqueCards,
      'remainingCards': remainingCards,
      'readinessLevel': readinessLevel,
    });
  }
  Future<void> incrementSession({
    required String moduleId,
  }) async {
    await _moduleRef(moduleId).update({
      'leitnerSessions': FieldValue.increment(1),
    });
  }

  Future<void> saveTestHistory({
    required String moduleId,
    required String moduleName,
    required int correctCount,
    required int totalAttempts,
    required int uniqueCards,
    required int remainingCards,
    required String readinessLevel,
  }) async {
    await _firestore
        .collection('Users')
        .doc(_userId)
        .collection('test_history')
        .add({
      'moduleId': moduleId,
      'moduleName': moduleName,
      'timestamp': FieldValue.serverTimestamp(),
      'correct': correctCount,
      'totalAttempts': totalAttempts,
      'uniqueCards': uniqueCards,
      'remainingCards': remainingCards,
      'readinessLevel': readinessLevel,
    });
  }
}