import 'package:coursework/components/my_button.dart';
import 'package:coursework/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursework/components/my_textfield.dart';
import 'package:coursework/components/square_title.dart';

class LoginPage extends StatefulWidget {

  final void Function()? onTap;
  const LoginPage ({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // метод для входа пользователя 
  void signUserIn() async {
    //загрузка 
    showDialog(context: context,
     builder: (context) => const Center(
      child: CircularProgressIndicator()
      ),
    );
    // try sign in 
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text);

        // loadind circle
        if (context.mounted) Navigator.pop(context);
    }
    //ошибки 
    on FirebaseAuthException catch (e) {
    // закрываем индикатор загрузки
    if (context.mounted) Navigator.pop(context);
    
    // обработка ошибок
    switch (e.code) {
      case 'invalid-email':
        displayMassageToUser('Неверный формат электронной почты.', context);
        break;
      case 'user-disabled':
        displayMassageToUser('Пользователь был отключен.', context);
        break;
      case 'user-not-found':
        displayMassageToUser('Пользователь не найден.', context);
        break;
      case 'wrong-password':
        displayMassageToUser('Неверный пароль.', context);
        break;
      case 'too-many-requests':
        displayMassageToUser('Слишком много запросов. Попробуйте позже.', context);
        break;
      case 'operation-not-allowed':
        displayMassageToUser('Аутентификация с использованием электронной почты и пароля отключена.', context);
        break;
      default:
        displayMassageToUser('Произошла ошибка. Пожалуйста, попробуйте еще раз.', context);
    }
  } catch (e) {
    // обрабатываем другие возможные исключения
    Navigator.pop(context);
    displayMassageToUser('Произошла ошибка: $e', context);
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Login',
          style: TextStyle(fontSize: 20),
          ),

      ),
      body: SafeArea(
        child: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /* const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ), */

              //const SizedBox(height: 200),

              // текст 
              Text(
                'Добро пожаловать! Войдите в систему',
                style: TextStyle(
                  //color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              //const SizedBox(height: 25),
              Padding(padding: EdgeInsets.only(top: 25),),

              // username textfield
              MyTextField(
                controller: emailController,
                hintText: 'e-mail',
                obscureText: false,
              ),

              //const SizedBox(height: 10),
              Padding(padding: EdgeInsets.only(top: 10),),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Пароль',
                obscureText: true,
              ),


              //если забыли пароль 
              //const SizedBox(height: 6),
              Padding(padding: EdgeInsets.only(top: 6),),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'забыли пароль?',
                      //style: TextStyle(color: const Color.fromARGB(255, 51, 57, 56)),
                    ),
                  ],
                ),
              ),

              //кнопка для входа 
              //const SizedBox(height: 50),
              Padding(padding: EdgeInsets.only(top: 50),),

              MyButton(
                text: 'войти',
                onTap: signUserIn,
              ),

              //const SizedBox(height: 120),
              Padding(padding: EdgeInsets.only(top: 120),),

              // взод через Google
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        //color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'или войдите через',
                        //style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        //color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              //const SizedBox(height: 20),
              Padding(padding: EdgeInsets.only(top: 20),),

              // google + apple sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // google button
                  SquareTile(imagePath: 'lib/images/google.png'),

                ],
              ),


              //const SizedBox(height: 20),
              Padding(padding: EdgeInsets.only(top: 20),),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'еще не зарегистрированы?',
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
    );
  }
}