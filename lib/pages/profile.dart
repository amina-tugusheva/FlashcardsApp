import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/theme/theme_providor.dart';
import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:coursework/services/auth_service.dart';
import 'package:coursework/services/profile_service.dart';
import 'package:coursework/components/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

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
            final newValue = controller.text.trim();
              if (newValue.isEmpty) return;

              final unique = await _profileService.isFieldUnique(
                field: field,
                value: newValue,
                currentUserId: currentUser.uid,
              );

              if (!unique) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('имя "$newValue" уже занято'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

            // Сохраняем
            await _profileService.updateField(
                userId: currentUser.uid,
                field: field,
                value: newValue,
              );

              if (!mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Имя изменено'),
                  backgroundColor: Colors.green,
                ),
              );
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
            onPressed: _isFormValid(
              currentPassController.text, 
              newPassController.text, 
              confirmPassController.text
              )
                ? () async {
                      Navigator.pop(context);
                      try {
                        await _authService.changePassword(
                          currentPassword: currentPassController.text,
                          newPassword: newPassController.text,
                        );

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Пароль изменён!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_authService.getAuthErrorMessage(e.code)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ошибка: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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
    return current.isNotEmpty &&
        newPass.isNotEmpty &&
        newPass.length >= 6 &&
        RegExp(r'[a-zA-Z]').hasMatch(newPass) &&
        RegExp(r'[0-9]').hasMatch(newPass) &&
        newPass == confirm;
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
              final password = passwordController.text.trim();
              if (password.isEmpty) return;

              try {
                await _profileService.deleteProfileData(currentUser.uid);
                await _authService.deleteAccount(password: password);

                if (!mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Аккаунт удалён'),
                    backgroundColor: Colors.green,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_authService.getAuthErrorMessage(e.code)),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка: $e'),
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

   Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть ссылку')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Профиль'),
      // ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _profileService.watchUser(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // final userData = snapshot.data!.data() as Map<String, dynamic>;
            if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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
                child: ProfileHeader(
                  username: userName,
                  subtitle: email,
                  avatarSize: 100,
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

              
              // Card(
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              //   child: Padding(
              //     padding: EdgeInsets.all(20),
              //     child: Column(
              //       children: [
              //         // Text(
              //         //   'Обучение',
              //         //   style: theme.textTheme.titleLarge?.copyWith(
              //         //     fontWeight: FontWeight.w600,
              //         //   ),
              //         // ),
              //         // SizedBox(height: 20),
              //         Row(
              //           children: [
              //             Expanded(child: _StatTile(icon: Icons.history, label: 'История', onTap: _goToHistory)),
              //             Expanded(child: _StatTile(icon: Icons.bar_chart, label: 'Статистика', onTap: _goToStats)),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 32),

              // Center(
              //   child: 
              //   Text(
              //   'Настройки',
              //   style: Theme.of(context).textTheme.titleMedium,
              // ),
              // ),
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
                        leading: const Icon(Icons.privacy_tip, 
                        // color: Colors.blue
                        ),
                        title: const Text('Политика конфиденциальности'),
                        subtitle: const Text('Как мы обрабатываем ваши данные'),
                        onTap: () => _launchURL('https://amina-tugusheva.github.io/FlashcardsApp/'),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(
                          Icons.description, 
                          // color: Colors.green
                          ),
                        title: const Text('Условия использования'),
                        subtitle: const Text('Правила работы с приложением'),
                        onTap: () => _launchURL('https://amina-tugusheva.github.io/FlashcardsApp/terms.html'),
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
}
