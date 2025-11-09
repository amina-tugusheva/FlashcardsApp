import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/my_button.dart';
import 'package:coursework/components/custom_button.dart';
import 'package:coursework/components/text_box.dart';
import 'package:coursework/theme/theme_providor.dart';
import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'test_history_page.dart';
import 'test_statistic_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  // пользователь
  final currentUser = FirebaseAuth.instance.currentUser!;

  //все пользователи 
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async{
    String newValue = "";
    await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
      title: Text("редактировать " + field),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: "введите новое $field",
          hintStyle: TextStyle(color:Colors.grey),
        ),
        onChanged: (value){
          newValue = value;
        },
      ),
      actions: [
        TextButton(
          
          child: Text('отменить'),
          onPressed: () => Navigator.pop(context), 
        ),

        TextButton(
          
          child: Text('сохранить'),
          onPressed: () => Navigator.of(context).pop(newValue), 
        ),
      ],
      )
    );

    //обновить Firestore
    if(newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.uid).update({field:newValue});
    }

  }

  //выход
  Future<void> logout () async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выход из аккаунта'),
          content: Text('Хотите выйти из аккаунта?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // логику выхода из аккаунта
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: Text('Да'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Профиль'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.uid)
        .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;


            return ListView(
              children: [

              Padding(padding: EdgeInsets.only(top: 25),),

              MyTextBox(
                text: currentUser.email!, 
                secondName: userData['имя пользователя'], 
                iconName: Icon(Icons.settings),
                onPressed: () => editField('имя пользователя'),
              ),

              Padding(padding: EdgeInsets.only(top: 25),),

              ElevatedButton(
              child: const Text('история'),
              onPressed: () {
                // Переход на экран со историей пройденных тестов 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestHistoryPage()),
                );
              },
            ),
              ElevatedButton(
                child: const Text('статистика'),
                onPressed: () {
                  // Переход на экран со историей пройденных тестов 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserStatisticsPage()),
                  );
                },
              ),
              CustomButton(
                text: 'тема', 
                icon: Icons.brightness_4, 
                onPressed:  () {
                  Provider.of<ThemeProvidor>(context, listen: false).toggletheme();
                },
              ),
              CustomButton(
                text: 'выход', 
                icon: Icons.logout, 
                onPressed: logout,
              ),

            ]

            );
          } else if (snapshot.hasError){
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      ),

    );
  }
}