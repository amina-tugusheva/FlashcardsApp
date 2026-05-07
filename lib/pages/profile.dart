import 'package:cloud_firestore/cloud_firestore.dart';
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
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

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

  Future<void> changePassword() async {
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Сменить пароль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Текущий пароль *',
                errorText: currentPassController.text.isEmpty 
                    ? 'Обязательно' 
                    : null,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: newPassController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Новый пароль *',
                errorText: _getPasswordError(newPassController.text),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: confirmPassController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль *',
                errorText: _getConfirmError(newPassController.text, confirmPassController.text),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена')),
          ElevatedButton(
            onPressed: _isFormValid(currentPassController.text, newPassController.text, confirmPassController.text)
                ? () => _changePasswordConfirmed(context, currentPassController, newPassController)
                : null,
            child: const Text('Сменить'),
          ),
        ],
      ),
    ),
  );
}

bool _isCurrentPasswordValid(String currentPass) => currentPass.isNotEmpty;

bool _isNewPasswordValid(String newPass) {
  return newPass.length >= 6 &&
         RegExp(r'[a-zA-Z]').hasMatch(newPass) &&  // Буквы
         RegExp(r'[0-9]').hasMatch(newPass);       // Цифры
}

String? _getPasswordError(String newPass) {
  if (newPass.isEmpty) return null;
  if (newPass.length < 6) return 'Минимум 6 символов';
  if (!RegExp(r'[a-zA-Z]').hasMatch(newPass)) return 'Добавьте буквы';
  if (!RegExp(r'[0-9]').hasMatch(newPass)) return 'Добавьте цифры';
  return null;
}

String? _getConfirmError(String newPass, String confirmPass) {
  if (confirmPass.isEmpty) return null;
  if (newPass != confirmPass) return 'Пароли не совпадают';
  return null;
}

bool _isFormValid(String current, String newPass, String confirm) {
  return _isCurrentPasswordValid(current) &&
         _isNewPasswordValid(newPass) &&
         newPass == confirm &&
         newPass.isNotEmpty;
}

Widget _getFormStatus(String current, String newPass, String confirm) {
  final isValid = _isFormValid(current, newPass, confirm);
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isValid ? Colors.green : Colors.red),
    ),
    child: Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.error, 
             color: isValid ? Colors.green : Colors.red),
        SizedBox(width: 8),
        Text(
          isValid 
            ? 'Готово для смены пароля' 
            : 'Заполните все поля корректно',
          style: TextStyle(
            color: isValid ? Colors.green[700] : Colors.red[700],
            fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

Future<void> _changePasswordConfirmed(BuildContext context,
    TextEditingController current, TextEditingController newPass) async {
  Navigator.pop(context);

  try {
    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: current.text,
      ),
    );
    await FirebaseAuth.instance.currentUser!.updatePassword(newPass.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пароль изменён!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e')),
    );
  }
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
              await currentUser.reauthenticateWithCredential(
                EmailAuthProvider.credential(
                  email: currentUser.email!,
                  password: passwordController.text,
                ),
              );

              await usersCollection.doc(currentUser.uid).delete();
              await currentUser.delete();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Аккаунт удалён'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              String errorMsg;
              if (e.toString().contains('wrong-password')) {
                errorMsg = 'Неверный пароль';
              } else if (e.toString().contains('network')) {
                errorMsg = 'Нет интернета';
              } else if (e.toString().contains('requires-recent-login')) {
                errorMsg = 'Войдите заново';
              } else {
                errorMsg = 'Ошибка: неверный пароль';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMsg),
                  backgroundColor: Colors.red,
                ),
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

  String _getEmojiByName(String name) {
  
  final emojis = [
    '😀', '😂', '🤓', '😎', '🥳', '🤩', '🦊', '🥰',
    '😇', '🤠', '😈', '👻', '👽', '🤖', '🎃', '🦄',
    '🐱', '🐶', '🐭', '🐹', '🐰', '😍', '🐻', '🐼',
    '🚀', '✈️', '🚗', '🚲', '🎸', '🎹', '🎤', '🎨',
  ];
  
  final index = name.toLowerCase().hashCode.abs() % emojis.length;
  return emojis[index];
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
                        colors: [
                          scheme.primary, 
                          scheme.primary.withOpacity(0.7)
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getEmojiByName(userName),  
                        style: const TextStyle(
                          fontSize: 50,  
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

              // const SizedBox(height: 32),

              // // Блок "статистика"
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
              //       MaterialPageRoute(builder: (context) => HistoryPage()),
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
                      //   'Обучение',
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
