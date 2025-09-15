import 'package:coursework/auth/auth.dart';
import 'package:coursework/theme/dark_mode.dart';
import 'package:coursework/theme/light_mode.dart';
import 'package:coursework/theme/theme_providor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/log_or_reg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
///
  /* await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); */
///
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
  runApp(
    //const MyApp()
    ChangeNotifierProvider(
      create: (context) => ThemeProvidor(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      //theme: lightMode,
      //darkTheme: darkMode,
      theme: Provider.of<ThemeProvidor>(context).themeData,

    );
  }
}

