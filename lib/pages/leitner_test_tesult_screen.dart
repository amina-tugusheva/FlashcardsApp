import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userCardsList.dart';
import 'package:coursework/theme/theme_providor.dart';
import 'package:provider/provider.dart';
import 'package:coursework/theme/dark_mode.dart';
import 'package:coursework/theme/light_mode.dart';

class LeitnerTestResultScreen extends StatelessWidget {
  final int correctCount;
  final int totalAttempts;
  final int uniqueCards;
  final int remainingCards;
  final String readinessLevel;
  final String leitnerRecommendation;
  final String moduleName;

  const LeitnerTestResultScreen({
    Key? key,
    required this.correctCount,
    required this.totalAttempts,
    required this.uniqueCards,
    required this.remainingCards,
    required this.readinessLevel,
    required this.leitnerRecommendation,
    required this.moduleName,
  }) : super(key: key);

 @override
Widget build(BuildContext context) {
  final successRate = totalAttempts > 0 ? (correctCount / totalAttempts * 100).round() : 0;

  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final textStyles = theme.textTheme;
  
  return Scaffold(
    appBar: AppBar(
      title: Text('Результаты: $moduleName'),
      centerTitle: true,
      ),
    body: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          // Icon(
          //   successRate >= 80 ? Icons.emoji_events : Icons.school,
          //   size: 80,
          //   color: successRate >= 80 ? Colors.amber : Colors.blue,
          // ),
          SizedBox(height: 24),
          
          Text(
            readinessLevel,
            // style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            style: textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            textAlign: TextAlign.center, 
          ),
          SizedBox(height: 32),
          
          // Карточки с фиксированной шириной
          Container(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Статистика сеанса:', 
                        style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                        //  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    _buildStatRow(context,'Правильных ответов', '$correctCount из $totalAttempts'),
                    _buildStatRow(context,'Уникальных карточек', '$uniqueCards'),
                    _buildStatRow(context,'Осталось выучить', '$remainingCards'),
                    _buildStatRow(context,'Точность', '${successRate}%'),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          
          Container(
            width: double.infinity,
            child: Card(
              // color: Colors.blue[50],
              color: colors.primaryContainer?.withOpacity(0.2),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Рекомендация Лейтнера:', 
                      style: textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                        //  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text(leitnerRecommendation, 
                         style: textStyles.bodyLarge?.copyWith(
                          color: colors.primary,
                        ),
                        //  style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                         textAlign: TextAlign.center,) 
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: Text(
                  'Вернуться к модулю',
                  style: textStyles.titleMedium,
                ),
                onPressed: () => Navigator.pop(context),
              ),
          ),
        ],
      ),
    ),
  );
}

// Вспомогательный метод для строк статистики
Widget _buildStatRow(BuildContext context, String label, String value) {
  final theme = Theme.of(context);
  final textStyles = theme.textTheme;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
}
}
