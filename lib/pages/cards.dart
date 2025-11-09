import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import "createCardScreen.dart";
import 'userCardsList.dart';

import 'moduleListPage.dart';

class CardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Главная')),
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        
        child: Column(
          children: [
            // ElevatedButton(
            //   child: const Text('Мои карточки'),
            //   onPressed: () {
            //     // Переход на экран со списком карточек пользователя
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => UserCardsList (moduleId: '5xsSct0aHoAprVMazSDl', moduleName: "phraseologisms",)),
            //     );
            //   },
            // ),
           
            SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Мои модули'),
              style: ElevatedButton.styleFrom(minimumSize: Size(500, 50)),
              onPressed: () {
                // Переход на экран со списком модулей пользователя
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModuleListPage()),
                );
              },
            ),
            // Здесь можно добавить кнопку или папку для сохранённых карточек других пользователей
          ],
        ),
      ),
    );
  }
}


// class CardsPage extends StatefulWidget {
//   @override
//   _CardsPageState createState() => _CardsPageState();

//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,

//   //       title: Text('Основная страница')
//   //     ),
//   //     body: Center(child: Text('Здесь будут карточки для обучения')),
//   //   );
//   // }
// }


// // функция схранения карточки в firestore
// Future<void> addCard(String title, String description) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     throw Exception('Пользователь не авторизован');
//   }

//   final cardsCollection = FirebaseFirestore.instance
//       .collection('Users')
//       .doc(user.email) // или user.uid
//       .collection('Cards');

//   final newCard = {
//     'title': title,
//     'description': description,
//     'createdAt': FieldValue.serverTimestamp(),
//   };

//   await cardsCollection.add(newCard);
// }
// /////////

// class _CardsPageState extends State<CardsPage> {
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _isSaving = false;

//   void _saveCard() async {
//     final title = _titleController.text.trim();
//     final description = _descriptionController.text.trim();

//     if (title.isEmpty || description.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Пожалуйста, заполните все поля')),
//       );
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await addCard(title, description);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Карточка успешно сохранена')),
//       );
//       _titleController.clear();
//       _descriptionController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Ошибка при сохранении: $e')),
//       );
//     } finally {
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Создать карточку')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: 'Термин'),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(labelText: 'Определение'),
//               maxLines: 4,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isSaving ? null : _saveCard,
//               child: _isSaving
//                   ? CircularProgressIndicator(color: Colors.white)
//                   : Text('Сохранить'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }