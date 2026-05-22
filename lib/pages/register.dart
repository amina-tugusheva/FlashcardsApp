
import 'package:coursework/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';  // Для Timer
import 'package:coursework/services/auth_service.dart';


class RegPage extends StatefulWidget {
  final void Function()? onTap;
  const RegPage({super.key, required this.onTap});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPWController = TextEditingController();

  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? usernameError;
  Timer? _debounceTimer;
  bool isCheckingUsername = false;
  bool isLoading = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPWController.dispose();
    super.dispose();
  }

  void _checkUsernameRealTime(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final username = value.trim();

      if (username.length < 3) {
        if (!mounted) return;
        setState(() {
          usernameError = null;
          isCheckingUsername = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() => isCheckingUsername = true);

      try {
        final unique = await _authService.isUsernameUnique(username);

        if (!mounted) return;
        setState(() {
          isCheckingUsername = false;
          usernameError = unique ? null : 'Имя пользователя занято';
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          isCheckingUsername = false;
          usernameError = 'Ошибка проверки';
        });
      }
    });
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Имя пользователя обязательно';
    if (value.length < 3) return 'Минимум 3 символа';
    return usernameError;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email обязателен';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Неверный формат email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Пароль обязателен';
    if (value.length < 6) return 'Минимум 6 символов';
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
      return 'Буквы + цифры';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Подтвердите пароль';
    if (value != passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  Future<void> regUserIn() async {
    if (!_formKey.currentState!.validate()) return;

    if (!await _authService.isUsernameUnique(usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Имя пользователя занято')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Проверьте почту для подтверждения аккаунта.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.getAuthErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Неизвестная ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
            vertical: 16.0,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Добро пожаловать! Зарегистрируйтесь',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: usernameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateUsername,
                      onChanged: _checkUsernameRealTime,
                      decoration: InputDecoration(
                        hintText: 'Имя пользователя',
                        suffixIcon: isCheckingUsername
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateEmail,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validatePassword,
                      decoration: InputDecoration(
                        hintText: 'Пароль',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          child: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPWController,
                      obscureText: obscureConfirmPassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Повторите пароль',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                          child: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 50),
                    MyButton(
                      text: isLoading ? 'Загрузка...' : 'зарегистрироваться',
                      onTap: isLoading ? null : regUserIn,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('уже зарегистрированы?'),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'войти',
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
      ),
    );
  }
}