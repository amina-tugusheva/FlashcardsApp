import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleModel {
  final String id;
  final String name;
  final String description;
  final String userId;
  final Timestamp createdAt;
  final int? cardsCount;
  final int? savesCount;
  final bool? isPublic;
  final bool? isSaved;
  final String? sourceAuthorName; // для отображения имени автора в сохраненных модулях
  // для отображения прогресса: 
  final int testSessions;           // TestScreen сессий (цель: 3)
  final int leitnerSessions;        // LeitnerScreen сессий (цель: 3)
  final int cardsInBox5;            // Выучено (box=5)
  final double overallProgress;     // ИТОГ 0.0-1.0

  ModuleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.createdAt,
    this.cardsCount,
    this.savesCount,
    this.isPublic,
    this.isSaved,
    this.sourceAuthorName,
    required this.testSessions,         
    required this.leitnerSessions,     
    required this.cardsInBox5,   
    required this.overallProgress,
  });

  factory ModuleModel.fromFirestore(DocumentSnapshot doc) {
    // Map data = doc.data() as Map<String, dynamic>;
    final data = doc.data() as Map<String, dynamic>;
    
    // БЕЗОПАСНЫЕ значения по умолчанию
    final cardsCount = data['cardsCount'] ?? 0;
    final savesCount = data['savesCount'] ?? 0;
    final cardsInBox5 = data['cardsInBox5'] ?? 0;
    final testSessionsRaw = data['testSessions'] ?? 0;
    final leitnerSessionsRaw = data['leitnerSessions'] ?? 0;
    
    // ВЫЧИСЛЯЕМ ПРОГРЕСС!
    final testProgress = (testSessionsRaw / 3.0).clamp(0.0, 1.0) * 0.3;
    final leitnerProgress = (leitnerSessionsRaw / 3.0).clamp(0.0, 1.0) * 0.3;
    final box5Progress = cardsCount > 0 
        ? (cardsInBox5 / cardsCount).clamp(0.0, 1.0) * 0.4 
        : 0.0;
    
    final overallProgress = (testProgress + leitnerProgress + box5Progress)
        .clamp(0.0, 1.0);

    return ModuleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      cardsCount: data['cardsCount'],
      savesCount: data['savesCount'],
      isPublic: data['isPublic'] ?? false,
      isSaved: data['isSaved'] ?? false,  
      sourceAuthorName: data['sourceAuthorName'] ?? '',
      testSessions: testSessionsRaw.toInt(),
      leitnerSessions: leitnerSessionsRaw.toInt(),
      cardsInBox5: cardsInBox5,
      overallProgress: overallProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'userId': userId,
      'createdAt': createdAt,
      'cardsCount': cardsCount,
      'savesCount': savesCount,
      'isPublic': isPublic ?? false,
      'isSaved': isSaved ?? false,
      'sourceAuthorName': sourceAuthorName,
      // Сохраняем статистику
      'testSessions': testSessions,
      'leitnerSessions': leitnerSessions,
      'cardsInBox5': cardsInBox5,
    };
  }
}