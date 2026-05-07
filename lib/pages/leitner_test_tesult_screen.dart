import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursework/components/module_model.dart';

class LeitnerTestResultScreen extends StatelessWidget {
  final int correctCount;
  final int totalAttempts;
  final int uniqueCards;
  final int remainingCards;
  final String readinessLevel;
  final String leitnerRecommendation;
  final String moduleName;
  final String moduleId; 

  const LeitnerTestResultScreen({
    Key? key,
    required this.correctCount,
    required this.totalAttempts,
    required this.uniqueCards,
    required this.remainingCards,
    required this.readinessLevel,
    required this.leitnerRecommendation,
    required this.moduleName,
    required this.moduleId,
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
          Text(
            readinessLevel,
            // style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            style: textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            textAlign: TextAlign.center, 
          ),
          SizedBox(height: 12),
          
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

          SizedBox(height: 16),  // НОВЫЙ БЛОК!
            
            // ПРОГРЕСС МОДУЛЯ
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('modules')
                  .doc(moduleId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final module = ModuleModel.fromFirestore(snapshot.data!);
                final progress = module.overallProgress;
                
                return Container(
                  width: double.infinity,
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Общий прогресс модуля',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
                              progress > 0.7 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${(progress * 100).round()}%',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Тестирование: ${module.leitnerSessions}/3 | Заучивание: ${module.testSessions}/3',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 4),
                          Text('Рекомендация Лейтнера:', 
                          style: textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                              //  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
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
                );
              },
            ),
          // SizedBox(height: 16),
          
          // Container(
          //   width: double.infinity,
          //   child: Card(
          //     // color: Colors.blue[50],
          //     color: colors.primaryContainer?.withOpacity(0.2),
          //     child: Padding(
          //       padding: EdgeInsets.all(20),
          //       child: Column(
          //         children: [
          //           Text('Рекомендация Лейтнера:', 
          //             style: textStyles.titleMedium?.copyWith(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //               //  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          //           SizedBox(height: 6),
          //           Text(leitnerRecommendation, 
          //                style: textStyles.bodyLarge?.copyWith(
          //                 color: colors.primary,
          //               ),
          //               //  style: TextStyle(fontSize: 16, color: Colors.blue[800]),
          //                textAlign: TextAlign.center,) 
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
              child: ElevatedButton.icon(
                // icon: const Icon(Icons.arrow_back),
                label: Text(
                  'Вернуться к модулю',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
