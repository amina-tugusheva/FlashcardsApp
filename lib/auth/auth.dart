import 'package:coursework/auth/log_or_reg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursework/pages/home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
       builder: (context, snapshop) {
        // пользователь уже зарегистрирован 
        if ( snapshop.hasData) {
          return const HomePage();
        }
        // пользователь еще не зарегистрирован 
        else {
          return const LogOrReg();
        }

       },
      ),

    );
    


  }
}