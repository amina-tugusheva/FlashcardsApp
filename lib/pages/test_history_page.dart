import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestHistoryPage extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser!;

  TestHistoryPage({Key? key}) : super(key: key);

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} '
        '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История тестов')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('test_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки истории: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Истории тестов пока нет'));
          }

          final historyDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: historyDocs.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final data = historyDocs[index].data()! as Map<String, dynamic>;

              final moduleName = data['moduleName'] ?? 'Без названия';
              final correct = data['correct'] ?? 0;
              final total = data['total'] ?? 0;
              final timestamp = data['timestamp'] as Timestamp?;

              return ListTile(
                leading: Icon(Icons.history),
                title: Text('Модуль: $moduleName'),
                subtitle: Text(
                  'Результат: $correct из $total\n'
                  'Дата: ${timestamp != null ? formatTimestamp(timestamp) : 'нет данных'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
