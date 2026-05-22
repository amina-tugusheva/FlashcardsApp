import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserStatisticsPage extends StatelessWidget {
  const UserStatisticsPage({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Без даты';
    return DateFormat('dd.MM.yyyy HH:mm').format(timestamp.toDate());
  }

  double _safePercent(int correct, int total) {
    if (total == 0) return 0;
    return (correct / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не авторизован')),
      );
    }

    final userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final historyStream = userRef
        .collection('test_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
    final modulesStream = userRef.collection('modules').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Общая статистика'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: historyStream,
        builder: (context, historySnapshot) {
          if (historySnapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки статистики'));
          }
          if (historySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final historyDocs = historySnapshot.data?.docs ?? [];

          int totalTests = historyDocs.length;
          int totalCorrect = 0;
          int totalAttempts = 0;
          int totalUniqueCards = 0;
          int bestResult = 0;

          for (final doc in historyDocs) {
            final data = doc.data();
            final correct = (data['correct'] ?? 0) as int;
            final attempts = (data['totalAttempts'] ?? 0) as int;
            final uniqueCards = (data['uniqueCards'] ?? 0) as int;

            totalCorrect += correct;
            totalAttempts += attempts;
            totalUniqueCards += uniqueCards;

            final percent = _safePercent(correct, attempts).round();
            if (percent > bestResult) bestResult = percent;
          }

          final averageSuccess = _safePercent(totalCorrect, totalAttempts);

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: modulesStream,
            builder: (context, modulesSnapshot) {
              if (modulesSnapshot.hasError) {
                return const Center(child: Text('Ошибка загрузки модулей'));
              }
              if (modulesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final moduleCount = modulesSnapshot.data?.docs.length ?? 0;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Общая статистика',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildStatRow('Всего тестов', totalTests.toString()),
                          _buildStatRow('Общий процент успеха',
                              '${averageSuccess.toStringAsFixed(1)}%'),
                          _buildStatRow('Правильных ответов', totalCorrect.toString()),
                          _buildStatRow('Всего попыток', totalAttempts.toString()),
                          _buildStatRow('Модулей', moduleCount.toString()),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              // color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}