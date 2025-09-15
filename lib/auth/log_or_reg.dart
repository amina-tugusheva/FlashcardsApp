import 'package:coursework/pages/login.dart';
import 'package:coursework/pages/register.dart';
import 'package:flutter/material.dart';

class LogOrReg extends StatefulWidget {
  const LogOrReg({super.key});

  @override
  State<LogOrReg> createState() => _LogOrRegState();
    
}

class _LogOrRegState extends State<LogOrReg>{

  bool ShowLoginPage = true;

  void togglePages() {
    setState(() {
      ShowLoginPage = !ShowLoginPage;

    });
  }

  @override
  Widget build(BuildContext context) {
    if (ShowLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegPage(onTap: togglePages);
    }
  }
}
