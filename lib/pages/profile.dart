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

              const SizedBox(height: 32),

              // Блок "статистика"
              Text(
                'Обучение',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('История'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestHistoryPage()),
                  );
                },
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text('Статистика'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserStatisticsPage()),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Блок "настройки" (отдельный, скролл общий у ListView)
              Text(
                'Настройки',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_4),
                      title: const Text('Тема'),
                      subtitle: Text(
                        'Светлая / тёмная',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Provider.of<ThemeProvidor>(context, listen: false).toggletheme();
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Выход'),
                      onTap: logout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],

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