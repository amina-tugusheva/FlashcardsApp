
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursework/components/square_title.dart';
import 'package:coursework/helper/helper_functions.dart';
import 'dart:async';  // Для Timer

class RegPage extends StatefulWidget {
  final void Function()? onTap;
  const RegPage ({super.key, required this.onTap});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();
  // text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPWController = TextEditingController();

  // Password visibility
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // // Состояния ошибок
  String? usernameError;
  // String? emailError;
  // String? passwordError;
  // String? confirmError;
  // bool isUsernameUnique = true;
  Timer? _debounceTimer;
  bool isCheckingUsername = false;


  // dispose() — метод жизненного цикла StatefulWidget, 
  // который вызывается перед удалением виджета из дерева. 
  // Освобождает память от контроллеров.
  @override
  void dispose() {
    _debounceTimer?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPWController.dispose();
    super.dispose();
  }

  // метод для регистрации пользователя 
  Future<void> regUserIn() async{
    
  //   // Проверка на пустоту полей
  // if (usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || confirmPWController.text.isEmpty) {
  //   Navigator.pop(context);
  //   displayMassageToUser('Все поля должны быть заполнены', context);
  //   return;
  // }

  // // Проверка уникальности username
  // var usernameCheck = await FirebaseFirestore.instance
  //   .collection('Users')
  //   .where('username', isEqualTo: usernameController.text)
  //   .limit(1)
  //   .get();
  // if (usernameCheck.docs.isNotEmpty) {
  //   displayMassageToUser('Имя пользователя занято', context);
  //   return;
  // }

  // // Проверка формата email
  // String emailPattern = r'^[^@]+@[^@]+.[^@]+';
  // RegExp regex = RegExp(emailPattern);
  // if (!regex.hasMatch(emailController.text)) {
  //   Navigator.pop(context);
  //   displayMassageToUser('Введите корректный email', context);
  //   return;
  // }

  // // Проверка первого и второго пароля на идентичность
  // if (passwordController.text != confirmPWController.text) {
  //   Navigator.pop(context);
  //   displayMassageToUser('Пароли не совпадают', context);
  //   return;
  // }

  // // Проверка минимальной длины пароля
  // if (passwordController.text.length < 6) { // например, минимальная длина пароля - 6 символов
  //   Navigator.pop(context);
  //   displayMassageToUser('Пароль должен содержать минимум 6 символов', context);
  //   return;
  // }
  // Проверка формы
  if (!_formKey.currentState!.validate()) return;

  if (!await checkUsernameUnique(usernameController.text)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Имя пользователя занято'))
  );
  return;
}
  // загрузка 
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
        ), 
      );

  try {
      UserCredential userCredential = 
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), // .trim для тот чтобы не было лишних пробелов до и после 
        password: passwordController.text,
      );
      // ОТПРАВИТЬ ПИСЬМО ПОДТВЕРЖДЕНИЯ
      await userCredential.user!.sendEmailVerification();

      // после создания пользователя, создание документа users в cloud firestore 
       FirebaseFirestore.instance
      .collection("Users")
      .doc(userCredential.user!.uid)
      .set({
        'имя пользователя' : usernameController.text.trim(),
        'email': userCredential.user!.email,
        'emailVerified': false,  // Отмечаем как НЕподтверждённый
        //добавить еще 
      }); 
      // Отправка письма для подтверждения email
    //await userCredential.user?.sendEmailVerification();
    Navigator.pop(context);
    //displayMassageToUser('Письмо для подтверждения отправлено на ваш email. Пожалуйста, подтвердите вашу почту.', context);
    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Проверьте почту для подтверждения аккаунта.'),
        backgroundColor: Colors.green,
      ),
    );
  }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getAuthErrorMessage(e.code)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) { // mounted — свойство State, показывает жив ли виджет в дереве на момент выполнения кода.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неизвестная ошибка: $e')),
        );
      }
    }
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.code))
    //   );
    // }
  }
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      default:
        return 'Ошибка: $code';
    }
  }

//   String _getErrorMessage(String code) {
//   switch (code) {
//     case 'email-already-in-use': return 'Email уже зарегистрирован';
//     case 'weak-password': return 'Пароль слишком слабый';
//     case 'invalid-email': return 'Неверный формат email';
//     default: return 'Ошибка: ${e.code}';
//   }
// }

// Реал-тайм проверка с задержкой 500мс
void _checkUsernameRealTime(String value) {
    // Отменяем предыдущий таймер
    _debounceTimer?.cancel();
    
    // Задержка перед запросом (debounce)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (value.trim().length < 3) {
        setState(() {
          usernameError = null;
          isCheckingUsername = false;
        });
        return;
      }

      setState(() => isCheckingUsername = true);
      
      try {
        var snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('имя пользователя', isEqualTo: value.trim())
            .limit(1)
            .get();
            
        setState(() {
          isCheckingUsername = false;
          usernameError = snapshot.docs.isNotEmpty 
              ? 'Имя пользователя занято' 
              : null;
        });
      } catch (e) {
        setState(() {
          isCheckingUsername = false;
          usernameError = 'Ошибка проверки';
        });
      }
    });
  }
// Валидаторы для реал-тайм проверки
  String? validateUsername(String? value) {
  if (value == null || value.isEmpty) return 'Имя пользователя обязательно';
  if (value.length < 3) return 'Минимум 3 символа';
  // return null; // Проверка уникальности отдельно
  return usernameError; // Показываем ошибку уникальности
}

// Проверка уникальности при отправке формы
Future<bool> checkUsernameUnique(String username) async {
  var snapshot = await FirebaseFirestore.instance
    .collection('Users')
    .where('имя пользователя', isEqualTo: username.trim())
    .limit(1)
    .get();
  return snapshot.docs.isEmpty;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // appBar: AppBar(
      //   // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(
      //     'Регистрация'
          
      //     //style: TextStyle(color: const Color.fromARGB(255, 51, 57, 56)),
      //     ),

      // ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.08,  // 5% от ширины экрана
          vertical: 16.0,    // 16px сверху/снизу
        ),
          child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  

                  const SizedBox(height: 50),

                  // текст 
                  Text(
                    'Добро пожаловать! Зарегистрируйтесь',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //color: Colors.grey[700],
                      fontSize: 16,
                      // fontWeight: FontWeight.w600
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Padding(padding: EdgeInsets.only(top: 25),),

                  // username textfield
                  // MyTextField(
                  //   controller: usernameController,
                  //   hintText: 'Имя пользователя',
                  //   obscureText: false,
                  // ),

                  // //const SizedBox(height: 10),
                  // Padding(padding: EdgeInsets.only(top: 10),),
                  TextFormField(
                    controller: usernameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction, //  Реал-тайм
                    validator: validateUsername,
                    onChanged: _checkUsernameRealTime, //  Реал-тайм проверка
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
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Email
                  // MyTextField(
                  //   controller: emailController,
                  //   hintText: 'e-mail',
                  //   obscureText: false,
                  // ),
                  
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateEmail,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      // prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  //const SizedBox(height: 10),
                  Padding(padding: EdgeInsets.only(top: 10),),

                  // // password textfield
                  // MyTextField(
                  //   controller: passwordController,
                  //   hintText: 'Пароль',
                  //   obscureText: true,
                  // ),
                  SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Пароль',
                      // prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        child: Icon(
                          obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  // //const SizedBox(height: 10),
                  // Padding(padding: EdgeInsets.only(top: 10),),

                  // // password textfield
                  // MyTextField(
                  //   controller: confirmPWController,
                  //   hintText: 'Повторите пароль',
                  //   obscureText: true,
                  // ),
                  SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: confirmPWController,
                    obscureText: obscureConfirmPassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: validateConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Повторите пароль',
                      // prefixIcon: Icon(Icons.lock_outline),
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
                          color: Colors.grey[600],
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  // SizedBox(height: 40),


                  //кнопка для входа 
                  const SizedBox(height: 50),
                  MyButton(
                    text: 'зарегистрироваться',
                    onTap: regUserIn,
                  ),

                  //const SizedBox(height: 90),
                  Padding(padding: EdgeInsets.only(top: 20),),
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

                  // const SizedBox(height: 20),
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
          
        ),
          ),
        
        
      ),
    
    );

  }
}