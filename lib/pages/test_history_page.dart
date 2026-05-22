// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class TestHistoryPage extends StatelessWidget {
//   final currentUser = FirebaseAuth.instance.currentUser!;

//   TestHistoryPage({Key? key}) : super(key: key);

//   String formatTimestamp(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} '
//         '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
//   }

//   String _twoDigits(int n) => n.toString().padLeft(2, '0');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('История тестов')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('Users')
//             .doc(currentUser.uid)
//             .collection('test_history')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Ошибка загрузки истории: ${snapshot.error}'));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('Истории тестов пока нет'));
//           }

//           final historyDocs = snapshot.data!.docs;

//           return ListView.separated(
//             padding: const EdgeInsets.all(8),
//             itemCount: historyDocs.length,
//             separatorBuilder: (_, __) => Divider(),
//             itemBuilder: (context, index) {
//               final data = historyDocs[index].data()! as Map<String, dynamic>;

//               final moduleName = data['moduleName'] ?? 'Без названия';
//               final correct = data['correct'] ?? 0;
//               final total = data['total'] ?? 0;
//               final timestamp = data['timestamp'] as Timestamp?;

//               return ListTile(
//                 leading: Icon(Icons.history),
//                 title: Text('Модуль: $moduleName'),
//                 subtitle: Text(
//                   'Результат: $correct из $total\n'
//                   'Дата: ${timestamp != null ? formatTimestamp(timestamp) : 'нет данных'}',
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestHistoryPage extends StatelessWidget {
  const TestHistoryPage({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Без даты';
    final date = timestamp.toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  Color _resultColor(String readinessLevel) {
    if (readinessLevel.contains('Отлично')) return Colors.green;
    if (readinessLevel.contains('Хорошо')) return Colors.teal;
    if (readinessLevel.contains('Удовлетворительно')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не авторизован')),
      );
    }

    final historyStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('test_history')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('История обучения'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: historyStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ошибка загрузки истории'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('История обучения пока пуста'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final moduleName = data['moduleName']?.toString() ?? 'Без названия';
              final readinessLevel = data['readinessLevel']?.toString() ?? '';
              final correct = data['correct'] ?? 0;
              final totalAttempts = data['totalAttempts'] ?? 0;
              final uniqueCards = data['uniqueCards'] ?? 0;
              final remainingCards = data['remainingCards'] ?? 0;
              final timestamp = data['timestamp'] as Timestamp?;

              final color = _resultColor(readinessLevel);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              moduleName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Icon(Icons.history, color: color),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        readinessLevel,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Дата: ${_formatDate(timestamp)}'),
                      Text('Правильных ответов: $correct'),
                      Text('Попыток: $totalAttempts'),
                      Text('Карточек в модуле: $uniqueCards'),
                      // Text('Осталось карточек: $remainingCards'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}