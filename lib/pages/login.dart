import 'package:coursework/components/my_button.dart';
import 'package:coursework/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursework/components/square_title.dart';
import 'dart:async'; // Для таймеров

class LoginPage extends StatefulWidget {

  final void Function()? onTap;
  const LoginPage ({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final resetEmailController = TextEditingController();

  // // Forgot password
  // final TextEditingController resetEmailController = TextEditingController();
  // bool _showResetDialog = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }

  // Вход с валидацией
  Future<void> signUserIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (context.mounted) Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError(_getAuthErrorMessage(e.code));
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError('Произошла ошибка: $e');
    }
  }

  // Сброс пароля 
  Future<void> _showResetPasswordDialog() async {
    resetEmailController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс пароля'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите email для отправки ссылки:'),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'ваш email',
                border: OutlineInputBorder(),
                // prefixIcon: Icon(Icons.email_outlined),
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
            onPressed: () {
              Navigator.pop(context);
              resetPassword();
            },
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.orange,
            //   foregroundColor: Colors.white,
            // ),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  // Отправка ссылки сброса
  Future<void> resetPassword() async {
    if (resetEmailController.text.trim().isEmpty) {
      _showError('Введите email');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: resetEmailController.text.trim(),
      );
      
      _showSuccess('Ссылка для сброса пароля отправлена на ${resetEmailController.text.trim()}!');
      
    } on FirebaseAuthException catch (e) {
      _showError(_getResetErrorMessage(e.code));
    } catch (e) {
      _showError('Ошибка отправки: $e');
    }
  }

  // Валидация email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email обязателен';
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(value.trim())) {
      return 'Неверный формат email';
    }
    return null;
  }

  // Валидация пароля
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль обязателен';
    }
    if (value.length < 6) {
      return 'Минимум 6 символов';
    }
    return null;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Аккаунт отключён';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'too-many-requests':
        return 'Много попыток. Подождите.';
      default:
        return 'Ошибка: $code';
    }
  }
// Сообщения об ошибках сброса
  String _getResetErrorMessage(String code) {
    switch (code) {
      case 'invalid-email': return 'Неверный email';
      case 'user-not-found': return 'Пользователь не найден';
      default: return 'Ошибка: $code';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [Icon(Icons.error, color: Colors.white), SizedBox(width: 8), Expanded(child: Text(message))]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Expanded(child: Text(message))]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(
      //     'Вход',
      //     style: TextStyle(fontSize: 20),
      //     ),

      // ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
            
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /* const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ), */

                const SizedBox(height: 50),

                // текст 
                Text(
                  'Добро пожаловать! Войдите в систему',
                  style: TextStyle(
                    //color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                
                const SizedBox(height: 32),

                  // Email поле с валидацией
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateEmail,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      // prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validatePassword,
                    decoration: const InputDecoration(
                      hintText: 'Пароль',
                      // prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),


                //  кнопка "забыли пароль"
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _showResetPasswordDialog,
                      child: const Text(
                        'Забыли пароль?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                // Кнопка входа
                  SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      text: 'Войти',
                      onTap: signUserIn,
                      
                    ),
                  ),
                  const SizedBox(height: 40),

                // // взод через Google
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Divider(
                //           thickness: 0.5,
                //           //color: Colors.grey[400],
                //         ),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //         child: Text(
                //           'или войдите через',
                //           //style: TextStyle(color: Colors.grey[700]),
                //         ),
                //       ),
                //       Expanded(
                //         child: Divider(
                //           thickness: 0.5,
                //           //color: Colors.grey[400],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // //const SizedBox(height: 20),
                // Padding(padding: EdgeInsets.only(top: 20),),

                // // google + apple sign in buttons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     // google button
                //     SquareTile(imagePath: 'lib/images/google.png'),

                //   ],
                // ),


                // //const SizedBox(height: 20),
                // Padding(padding: EdgeInsets.only(top: 20),),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'не зарегистрированы?',
                      //style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                      'зарегистрироваться',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                  ],
                ),
              ],
            ),

            ),
          ),
        ),
        
        
      ),
    );
  }
}