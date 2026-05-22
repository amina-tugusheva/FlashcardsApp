import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/module_model.dart';
class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String userId) {
    return _firestore.collection('Users').doc(userId).snapshots();
  }

  Stream<List<ModuleModel>> watchPublicModules(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('modules')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ModuleModel.fromFirestore(doc)).toList());
  }

  Future<int> countPublicModules(String userId) async {
    final snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('modules')
        .where('isPublic', isEqualTo: true)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<void> updateField({
    required String userId,
    required String field,
    required String value,
  }) async {
    await _firestore.collection('Users').doc(userId).update({
      field: value,
    });
  }

  Future<bool> isFieldUnique({
    required String field,
    required String value,
    required String currentUserId,
  }) async {
    final existing = await _firestore
        .collection('Users')
        .where(field, isEqualTo: value)
        .limit(1)
        .get();

    return existing.docs.isEmpty || existing.docs.first.id == currentUserId;
  }

  Future<void> deleteProfileData(String userId) async {
    await _firestore.collection('Users').doc(userId).delete();
  }
}