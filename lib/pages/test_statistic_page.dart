import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatisticsPage extends StatefulWidget {
  const UserStatisticsPage({Key? key}) : super(key: key);

  @override
  _UserStatisticsPageState createState() => _UserStatisticsPageState();
}

class _UserStatisticsPageState extends State<UserStatisticsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  int modulesCount = 0;
  int cardsCount = 0;
  int testsCount = 0;
  double averageScorePercent = 0.0;
  int bestCorrect = 0;

  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      // Получаем модули
      final modulesSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .get();

      modulesCount = modulesSnapshot.docs.length;

      // Считаем карточки во всех модулях
      cardsCount = 0;
      for (final moduleDoc in modulesSnapshot.docs) {
        final cardsSnapshot = await moduleDoc.reference.collection('user_cards').get();
        cardsCount += cardsSnapshot.docs.length;
      }

      // Загружаем историю тестов
      final testHistorySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('test_history')
          .get();

      testsCount = testHistorySnapshot.docs.length;

      if (testsCount > 0) {
        int totalCorrect = 0;
        bestCorrect = 0;

        for (final doc in testHistorySnapshot.docs) {
          final data = doc.data();
          int correct = (data['correct'] ?? 0) as int;
          int total = (data['total'] ?? 1) as int;

          totalCorrect += correct;
          if (correct > bestCorrect) bestCorrect = correct;
        }

        averageScorePercent = totalCorrect / testHistorySnapshot.docs.fold<int>(0, (prev, d) {
          final total = (d.data()['total'] ?? 1) as int;
          return prev + total;
        }) * 100;
      } else {
        averageScorePercent = 0;
        bestCorrect = 0;
      }
    } catch (e) {
      errorMsg = 'Ошибка загрузки статистики: $e';
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Статистика')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Статистика')),
        body: Center(child: Text(errorMsg!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatRow(label: 'Количество модулей', value: modulesCount.toString()),
            StatRow(label: 'Количество карточек', value: cardsCount.toString()),
            Divider(),
            StatRow(label: 'Количество пройденных тестов', value: testsCount.toString()),
            StatRow(label: 'Средний результат (%)', value: averageScorePercent.toStringAsFixed(1)),
            StatRow(label: 'Лучший результат', value: bestCorrect.toString()),
            Divider(),
            // Если хотите — добавьте отслеживание времени в приложении и отобразите здесь
          ],
        ),
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
