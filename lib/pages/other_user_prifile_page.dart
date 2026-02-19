import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursework/components/my_button.dart';
import 'package:coursework/components/text_box.dart'; // предполагаю, что MyTextBox это text_box.dart
import 'package:coursework/theme/theme_providor.dart';
import 'package:provider/provider.dart';


import 'package:coursework/components/module_model.dart';
import 'package:flutter/material.dart';

class PublicUserProfilePage extends StatelessWidget {
  final String otherUserId;
  final String otherUserName;

  const PublicUserProfilePage({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyles = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary,
                colors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Аватар
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colors.onPrimary,
                      child: Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : '?',
                        style: textStyles.headlineSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Имя пользователя
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            otherUserName,
                            style: textStyles.titleLarge?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Модули',
                            style: textStyles.bodyLarge?.copyWith(
                              color: colors.onPrimary.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // body: Container(
      //   width: double.infinity,
      //   padding: const EdgeInsets.all(24),
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [
      //         colors.primary,
      //         colors.primary.withOpacity(0.8),
      //       ],
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //     ),
      //   ),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       // Аватар
      //       CircleAvatar(
      //         radius: 50,
      //         backgroundColor: colors.onPrimary,
      //         child: Text(
      //           otherUserName.isNotEmpty 
      //               ? otherUserName[0].toUpperCase()
      //               : '?',
      //           style: textStyles.headlineMedium?.copyWith(
      //             color: colors.primary,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 40,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 24),
            
      //       // Имя пользователя
      //       Text(
      //         otherUserName,
      //         style: textStyles.headlineLarge?.copyWith(
      //           color: colors.onPrimary,
      //           fontWeight: FontWeight.bold,
      //         ),
      //         textAlign: TextAlign.center,
      //       ),
      //       const SizedBox(height: 16),
            
      //       // Подзаголовок
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //         decoration: BoxDecoration(
      //           color: colors.onPrimary.withOpacity(0.2),
      //           borderRadius: BorderRadius.circular(20),
      //         ),
      //         child: Text(
      //           'Пользователь',
      //           style: textStyles.titleMedium?.copyWith(
      //             color: colors.onPrimary,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 32),
            
      //       // Кнопка "Смотреть модули" (пока заглушка)
      //       SizedBox(
      //         width: double.infinity,
      //         child: OutlinedButton.icon(
      //           icon: const Icon(Icons.folder_special),
      //           label: const Text('Смотреть модули'),
      //           style: OutlinedButton.styleFrom(
      //             foregroundColor: colors.onPrimary,
      //             side: BorderSide(color: colors.onPrimary.withOpacity(0.5)),
      //             padding: const EdgeInsets.symmetric(vertical: 16),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(16),
      //             ),
      //           ),
      //           onPressed: () {
      //             // Пока пустая заглушка
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(
      //                 content: Text('Модули скоро появятся!'),
      //                 duration: Duration(seconds: 2),
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
// class OtherUserProfilePage extends StatefulWidget {
//   final String otherUserUid;
  
//   const OtherUserProfilePage({
//     super.key,
//     required this.otherUserUid,
//   });

//   @override
//   State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
// }

// class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
//   final usersCollection = FirebaseFirestore.instance.collection("Users");

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Профиль пользователя'),
//         // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: usersCollection.doc(widget.otherUserUid).snapshots(),
//         builder: (context, snapshot) {
//           // Обработка ошибок
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Ошибка: ${snapshot.error}'),
//             );
//           }
          
//           // Проверка на существование данных
//           // if (!snapshot.hasData || !snapshot.data!.exists) {
//           //   return const Center(
//           //     child: Text('Пользователь не найден'),
//           //   );
//           // }

//           // Безопасное получение данных
//           final userData = snapshot.data!.data() as Map<String, dynamic>?;
//           if (userData == null) {
//             return const Center(
//               child: Text('Нет данных пользователя'),
//             );
//           }

//           // Имя пользователя из Firestore (как сохраняется в вашей регистрации)
//           final userName = userData['имя пользователя'] ?? 'Не указано';
//           final userEmail = userData['email'] ?? 'Не указано';

//           return ListView(
//             children: [
//               const Padding(padding: EdgeInsets.only(top: 25)),

//               // Отображение имени пользователя (нельзя редактировать)
//               MyTextBox(
//                 text: userEmail,
//                 secondName: userName,
//                 iconName: const Icon(Icons.person),
//                 onPressed: null, // Запрещаем редактирование чужого профиля
//               ),

//               const SizedBox(height: 32),

//               // Заголовок "Обучение" (информационный)
//               Text(
//                 'Обучение',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 12),

//               // Информационные кнопки (без функционала)
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.history),
//                         title: const Text('История'),
//                         subtitle: const Text('Доступна только владельцу'),
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.bar_chart),
//                         title: const Text('Статистика'),
//                         subtitle: const Text('Доступна только владельцу'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Кнопка "Назад"
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                 child: MyButton(
//                   text: 'Назад',
//                   onTap: () => Navigator.pop(context),
//                 ),
//               ),

//               const SizedBox(height: 24),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
