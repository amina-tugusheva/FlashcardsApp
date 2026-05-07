import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/pages/other_user_prifile_page.dart';

import 'userCardsList.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  final modulesCollection = FirebaseFirestore.instance.collectionGroup('modules');
  
  late TabController _tabController;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => searchResults = []);
      return;
    }

    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> results = [];
      final q = query.trim();

      if (_tabController.index == 0) { // 👥 Пользователи
        final snapshot = await usersCollection
            .where('имя пользователя',
                isGreaterThanOrEqualTo: q,
                isLessThanOrEqualTo: q + '\uf8ff')
            .limit(20)
            .get();

        results = snapshot.docs.map((doc) => {
          'type': 'user',
          'id': doc.id!,
          'name': doc['имя пользователя'] ?? 'Без имени',
          'email': doc['email'] ?? '',
        }).toList();

      } else { 
        final snapshot = await modulesCollection
            .where('name',
                isGreaterThanOrEqualTo: q,
                isLessThanOrEqualTo: q + '\uf8ff')
            .where('isPublic', isEqualTo: true)
            .orderBy('cardsCount', descending: true)
            .limit(20)
            .get();

        results = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'type': 'module',
            'id': doc.id!,
            'name': data['name'] ?? 'Без названия',
            'cardsCount': data['cardsCount'] ?? 0,
            'userId': doc.reference.parent.parent!.id,
            'description': data['description']?.toString() ?? '',
          };
        }).toList();
      }

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка поиска: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Поиск...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                setState(() => searchResults = []);
              },
            ),
          ),
          onChanged: (value) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _search(value);
              }
            });
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Пользователи'),
            Tab(icon: Icon(Icons.menu_book), text: 'Модули'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 👥 Пользователи → профиль
                _buildResultsList(
                  context,
                  searchResults.where((r) => r['type'] == 'user').toList(),
                  Icons.people,
                  'Пользователи не найдены',
                ),
                _buildResultsList(
                  context,
                  searchResults.where((r) => r['type'] == 'module').toList(),
                  Icons.menu_book,
                  'Модули не найдены',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Map<String, dynamic>> results, 
      IconData emptyIcon, String emptyText) {
    if (results.isEmpty && _searchController.text.trim().isNotEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyText, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Попробуйте другое название', 
                 style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        
        if (item['type'] == 'user') {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(item['name'][0].toUpperCase()),
              ),
              title: Text(item['name']),
              subtitle: Text(item['email'].isNotEmpty ? item['email'] : 'Модули доступны'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicUserProfilePage(
                    targetUserId: item['id'],
                    targetUsername: item['name'],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Text('${item['cardsCount']}'),
              ),
              title: Text(item['name']),
              subtitle: Text(
                item['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserCardsList(
                    moduleId: item['id']?.toString() ?? 'unknown',
                    moduleName: item['name']?.toString() ?? 'Без названия',
                    authorId: item['userId']?.toString() ?? '',
                    isPublicStudy: true,  
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
