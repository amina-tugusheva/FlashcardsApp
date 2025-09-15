
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursework/components/my_textfield.dart';
import 'package:coursework/components/square_title.dart';
import 'package:coursework/helper/helper_functions.dart';

class RegPage extends StatefulWidget {
  final void Function()? onTap;
  const RegPage ({super.key, required this.onTap});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final emaileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPWController = TextEditingController();

  // метод для регистрации пользователя 
  void regUserIn() async{
    // загрузка 
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
        ), 
      );
    //проверка первого и второго пароля на идентичность
    // Проверка на пустоту полей
  if (usernameController.text.isEmpty || emaileController.text.isEmpty || passwordController.text.isEmpty || confirmPWController.text.isEmpty) {
    Navigator.pop(context);
    displayMassageToUser('Все поля должны быть заполнены', context);
    return;
  }

  // Проверка формата email
  String emailPattern = r'^[^@]+@[^@]+.[^@]+';
  RegExp regex = RegExp(emailPattern);
  if (!regex.hasMatch(emaileController.text)) {
    Navigator.pop(context);
    displayMassageToUser('Введите корректный email', context);
    return;
  }

  // Проверка первого и второго пароля на идентичность
  if (passwordController.text != confirmPWController.text) {
    Navigator.pop(context);
    displayMassageToUser('Пароли не совпадают', context);
    return;
  }

  // Проверка минимальной длины пароля
  if (passwordController.text.length < 6) { // например, минимальная длина пароля - 6 символов
    Navigator.pop(context);
    displayMassageToUser('Пароль должен содержать минимум 6 символов', context);
    return;
  }
  try {
      UserCredential userCredential = 
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emaileController.text, 
        password: passwordController.text,
      );

      // после создания пользователя, создание документа users в cloud firestore 
       FirebaseFirestore.instance
      .collection("Users")
      .doc(userCredential.user!.uid)
      .set({
        'имя пользователя' : usernameController.text,
        'email': userCredential.user!.email,
        //добавить еще 
      }); 
      // Отправка письма для подтверждения email
    //await userCredential.user?.sendEmailVerification();
    Navigator.pop(context);
    //displayMassageToUser('Письмо для подтверждения отправлено на ваш email. Пожалуйста, подтвердите вашу почту.', context);
    
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMassageToUser(e.code, context);
    }
    
      
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Login'
          
          //style: TextStyle(color: const Color.fromARGB(255, 51, 57, 56)),
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
                'Добро пожаловать! Зарегистрируйтесь',
                style: TextStyle(
                  //color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              //const SizedBox(height: 25),
              Padding(padding: EdgeInsets.only(top: 25),),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Имя пользователя',
                obscureText: false,
              ),

              //const SizedBox(height: 10),
              Padding(padding: EdgeInsets.only(top: 10),),

              MyTextField(
                controller: emaileController,
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

              //const SizedBox(height: 10),
              Padding(padding: EdgeInsets.only(top: 10),),

              // password textfield
              MyTextField(
                controller: confirmPWController,
                hintText: 'Повторите пароль',
                obscureText: true,
              ),


              //кнопка для входа 
              const SizedBox(height: 50),
              MyButton(
                text: 'зарегистрироваться',
                onTap: regUserIn,
              ),

              //const SizedBox(height: 90),
              Padding(padding: EdgeInsets.only(top: 90),),
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
                    'уже зарегистрированы?',
                    //style: TextStyle(color: Colors.grey[700]),
                  ),
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
    
    );

  }
}