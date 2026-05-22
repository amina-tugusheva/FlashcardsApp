import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';  // Для Timer
import 'home.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  bool _isVerifying = true;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    _startVerificationTimer();
  }

  // Проверяем статус верификации
  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Обновляем данные с сервера
      setState(() {
        _isVerifying = !user.emailVerified;
      });
      
      if (user.emailVerified) {
        _goToHome();
      }
    }
  }

  // Таймер автоматической проверки
  void _startVerificationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkEmailVerification();
    });
  }

  // Повторная отправка письма
  Future<void> _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Письмо отправлено повторно!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _goToHome() {
    _timer?.cancel();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(

      appBar: AppBar(
          title: const Text('Подтверждение email'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 100,
              ),
              const SizedBox(height: 32),
              
              Text(
                _isVerifying ? 'Подтвердите email' : 'Email подтверждён!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isVerifying ? _resendVerificationEmail : null,
                style: ElevatedButton.styleFrom(
                ),
                child: const Text('Отправить письмо ещё раз'),
              ),
              
              const SizedBox(height: 24),
              const Text(
                'Проверьте почту.\nПисьмо приходит за 2-3 минуты.',
                textAlign: TextAlign.center,
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
