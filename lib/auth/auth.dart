import 'package:coursework/auth/log_or_reg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursework/pages/home.dart';

import 'package:coursework/pages/email_verification.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // НЕ АВТОРИЗОВАН
          if (!snapshot.hasData) {
            return const LogOrReg();
          }

          User user = snapshot.data!;

          // АВТОРИЗОВАН + EMAIL ПОДТВЕРЖДЁН 
          if (user.emailVerified) {
            return const HomePage();
          }

          // АВТОРИЗОВАН, НО EMAIL НЕ ПОДТВЕРЖДЁН 
          return const EmailVerificationPage();
        },
      ),

    );
  }
}