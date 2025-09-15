import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userCardsList.dart';

class LeitnerTestTesultScreen extends StatelessWidget {
  final int correctCount;
  final int total;
  final List<bool> results; // Можно использовать для детальной статистики
  final String moduleName;

  const LeitnerTestTesultScreen({
    Key? key,
    required this.correctCount,
    required this.total,
    required this.results,
    required this.moduleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int wrongCount = total - correctCount;
    double percent = total > 0 ? (correctCount / total) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: Text('Результаты теста')),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Модуль: $moduleName',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('Правильных ответов: $correctCount из $total',
                style: TextStyle(fontSize: 20, color: Colors.green)),
            Text('Ошибок: $wrongCount',
                style: TextStyle(fontSize: 18, color: Colors.redAccent)),
            Text('Процент правильных: ${percent.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Вернуться'),
              style:
                  ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40)),
            ),
          ],
        ),
      ),
    );
  }
}
