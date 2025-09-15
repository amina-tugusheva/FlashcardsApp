import 'package:flutter/material.dart';


class TestResultScreen extends StatelessWidget {
  final int correctCount;
  final int total;
  final List<bool> results;

  const TestResultScreen({
    Key? key,
    required this.correctCount,
    required this.total,
    required this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Результаты теста')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Правильных ответов: $correctCount из $total',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Ошибок: ${total - correctCount}',
                style: TextStyle(color: Colors.red, fontSize: 16)),
              ElevatedButton(
                child: Text('Вернуться'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
}
