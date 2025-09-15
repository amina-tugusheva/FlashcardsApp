import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleModel {
  final String id;
  final String name;
  final String description;
  final String userId;
  final Timestamp createdAt;

  ModuleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.createdAt,
  });

  factory ModuleModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ModuleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}