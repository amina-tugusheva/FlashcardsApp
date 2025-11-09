import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  //       title: Text('Поиск')
  //     ),
  //     body: Center(child: Text('Здесь будет функция поиска')),
  //   );
  // }
}
class _SearchPageState extends State<SearchPage> {
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  void searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await usersCollection
          .where('имя пользователя',
              isGreaterThanOrEqualTo: query,
              isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final results = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка поиска: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Поиск пользователей')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Введите имя пользователя',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                searchUsers(val.toLowerCase());
              },
            ),
          ),
          if (isLoading) LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                final username = user['имя пользователя'] ?? 'Без имени';
                // final email = user['email'] ?? 'Без email';

                return ListTile(
                  title: Text(username),
                  //subtitle: Text(email),
                  onTap: () {
                    // Действия при выборе пользователя (например, перейти в профиль)
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}