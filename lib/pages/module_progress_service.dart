import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModuleProgressService {
  static Future<void> updateModuleStats(String moduleId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final moduleRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('modules')
        .doc(moduleId);

    // Подсчёт box=5
    final box5Query = await moduleRef.collection('user_cards')
        .where('box', isEqualTo: 5).get();
    
    final totalQuery = await moduleRef.collection('user_cards').get();

    await moduleRef.update({
      'cardsInBox5': box5Query.size,
      'cardsCount': totalQuery.size,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
