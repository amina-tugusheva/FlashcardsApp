import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/my_button.dart';
import 'package:coursework/components/custom_button.dart';
import 'package:coursework/components/text_box.dart';
import 'package:coursework/theme/theme_providor.dart';
import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'test_history_page.dart';
import 'test_statistic_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  // пользователь
  final currentUser = FirebaseAuth.instance.currentUser!;

  //все пользователи 
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // // функция редактрования имени пользоателя 
  // Future<void> editField(String field) async{
  //   String newValue = "";
  //   await showDialog(
  //     context: context, 
  //     builder: (context) => AlertDialog(
  //     title: Text("редактировать " + field),
  //     content: TextField(
  //       autofocus: true,
  //       decoration: InputDecoration(
  //         hintText: "введите новое $field",
  //         hintStyle: TextStyle(color:Colors.grey),
  //       ),
  //       onChanged: (value){
  //         newValue = value;
  //       },
  //     ),
  //     actions: [
  //       TextButton(
          
  //         child: Text('отменить'),
  //         onPressed: () => Navigator.pop(context), 
  //       ),

  //       TextButton(
          
  //         child: Text('сохранить'),
  //         onPressed: () => Navigator.of(context).pop(newValue), 
  //       ),
  //     ],
  //     )
  //   );

  //   //обновить Firestore
  //   if(newValue.trim().length > 0) {
  //     await usersCollection.doc(currentUser.uid).update({field:newValue});
  //   }

  // }
  Future<void> editField(String field) async {
  final TextEditingController controller = TextEditingController();
  
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Редактировать $field"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Введите новое $field",
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        ElevatedButton(
          onPressed: () async {
            String newValue = controller.text.trim();
            if (newValue.isEmpty) return;

            // Проверка уникальности
            QuerySnapshot existing = await usersCollection
                .where(field, isEqualTo: newValue)
                .limit(1)
                .get();

            if (existing.docs.isNotEmpty && 
                existing.docs.first.id != currentUser.uid) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('имя "$newValue" уже занято'), backgroundColor: Colors.red),
                );
              }
              return;
            }

            // Сохраняем
            await usersCollection.doc(currentUser.uid).update({field: newValue});
            Navigator.pop(context);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Имя изменено'), backgroundColor: Colors.green),
              );
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
}

  // СМЕНА ПАРОЛЯ
  Future<void> changePassword() async {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сменить пароль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Текущий пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль (6+ символов)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Подтвердите новый пароль',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              String currentPass = currentPassController.text;
              String newPass = newPassController.text;
              String confirmPass = confirmPassController.text;

              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пароль должен быть 6+ символов')),
                );
                return;
              }

              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пароли не совпадают')),
                );
                return;
              }

              try {
                // Ре-аутентификация
                await currentUser.reauthenticateWithCredential(
                  EmailAuthProvider.credential(
                    email: currentUser.email!,
                    password: currentPass,
                  ),
                );

                // Смена пароля
                await currentUser.updatePassword(newPass);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пароль успешно изменён'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
            child: const Text('Сменить'),
          ),
        ],
      ),
    );
  }

  // УДАЛЕНИЕ ПРОФИЛЯ
  Future<void> deleteAccount() async {
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Это действие НЕОБРАТИМО!\nВсе данные будут удалены.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Введите пароль для подтверждения',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                // Ре-аутентификация
                await currentUser.reauthenticateWithCredential(
                  EmailAuthProvider.credential(
                    email: currentUser.email!,
                    password: passwordController.text,
                  ),
                );

                // Удаляем Firestore данные
                await usersCollection.doc(currentUser.uid).delete();

                // Удаляем аккаунт
                await currentUser.delete();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Аккаунт удалён'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //выход
  Future<void> logout () async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выход из аккаунта'),
          content: Text('Хотите выйти из аккаунта?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // логику выхода из аккаунта
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: Text('Да'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
  


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Профиль'),
      // ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.uid)
        .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final userName = userData['имя пользователя'] ?? 'Без имени';
            final email = currentUser.email ?? 'Не указан';
            return ListView(
              children: [

              Padding(padding: EdgeInsets.only(top: 25),),

              // MyTextBox(
              //   text: currentUser.email!, 
              //   secondName: userData['имя пользователя'], 
              //   iconName: Icon(Icons.settings),
              //   onPressed: () => editField('имя пользователя'),
              // ),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Блок "статистика"
              // Text(
              //   'Обучение',
              //   style: Theme.of(context).textTheme.titleMedium,
              // ),
              // const SizedBox(height: 12),

              // ElevatedButton.icon(
              //   icon: const Icon(Icons.history),
              //   label: const Text('История'),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => TestHistoryPage()),
              //     );
              //   },
              // ),
              // const SizedBox(height: 12),

              // ElevatedButton.icon(
              //   icon: const Icon(Icons.bar_chart),
              //   label: const Text('Статистика'),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => UserStatisticsPage()),
              //     );
              //   },
              // ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Text(
                      //   '📊 Обучение',
                      //   style: theme.textTheme.titleLarge?.copyWith(
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      // SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _StatTile(icon: Icons.history, label: 'История', onTap: _goToHistory)),
                          Expanded(child: _StatTile(icon: Icons.bar_chart, label: 'Статистика', onTap: _goToStats)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Блок "настройки" (отдельный, скролл общий у ListView)
              Center(
                child: 
                Text(
                'Настройки',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ),
              const SizedBox(height: 12),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_4),
                      title: const Text('Тема'),
                      subtitle: Text(
                        'Светлая / тёмная',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Provider.of<ThemeProvidor>(context, listen: false).toggletheme();
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Редактировать имя'),
                      // subtitle: userName,
                      onTap: () => editField('имя пользователя'),
                    ),
                    const Divider(height: 0),

                    ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Сменить пароль'),
                        onTap: changePassword, 
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.delete_forever),
                        title: const Text('Удалить аккаунт'),
                        textColor: Colors.red,
                        onTap: deleteAccount, 
                      ),
                      const Divider(height: 0),

                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Выход'),
                      onTap: logout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],

            );
          } else if (snapshot.hasError){
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      ),

    );
  }

  Widget _StatTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            SizedBox(height: 8),
            Text(label, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
  void _goToHistory() => Navigator.push(context, MaterialPageRoute(builder: (_) => TestHistoryPage()));
  void _goToStats() => Navigator.push(context, MaterialPageRoute(builder: (_) => UserStatisticsPage()));

}