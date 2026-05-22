import 'package:flutter/material.dart'; 
import 'dart:async';  // Для Tim
import 'package:coursework/components/module_search_title.dart';
import 'package:coursework/components/user_search_title.dart';
import 'package:coursework/services/search_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  late TabController _tabController;
  Timer? _debounce;

  List<Map<String, dynamic>> userResults = [];
  List<Map<String, dynamic>> moduleResults = [];
  bool isLoading = false;
  // final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final query = _searchController.text.trim();
      if (query.isNotEmpty) _search(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    final q = query.trim();

    if (q.length < 2) {
      if (!mounted) return;
      setState(() {
        userResults = [];
        moduleResults = [];
        isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      if (_tabController.index == 0) {
        final users = await _searchService.searchUsers(q);
        if (!mounted) return;
        setState(() {
          userResults = users;
          isLoading = false;
        });
      } else {
        final modules = await _searchService.searchModules(q);
        if (!mounted) return;
        setState(() {
          moduleResults = modules;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        userResults = [];
        moduleResults = [];
        isLoading = false;
      });
      debugPrint('Ошибка поиска: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

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
            suffixIcon: 
            // IconButton(
            //   icon: 
              Icon(Icons.clear, color: Colors.white70),
              // onPressed: () {
              //   _searchController.clear();
              //   setState(() => searchResults = []);
              // },
            // ),
          ),
          onChanged: _onSearchChanged,
          
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
                _buildUserResults(),
                _buildModuleResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserResults() {
    if (userResults.isEmpty && _searchController.text.trim().isNotEmpty && !isLoading) {
      return _emptyState(Icons.people, 'Пользователи не найдены');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userResults.length,
      itemBuilder: (context, index) {
        final item = userResults[index];
        return UserSearchTile(
          userId: item['id']?.toString() ?? '',
          name: item['name']?.toString() ?? 'Без имени',
          email: item['email']?.toString() ?? '',
          avatarUrl: item['avatarUrl']?.toString() ?? '',
        );
      },
    );
  }

  Widget _buildModuleResults() {
    if (moduleResults.isEmpty && _searchController.text.trim().isNotEmpty && !isLoading) {
      return _emptyState(Icons.menu_book, 'Модули не найдены');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: moduleResults.length,
      itemBuilder: (context, index) {
        final item = moduleResults[index];
        return ModuleSearchTile(
          moduleId: item['id']?.toString() ?? '',
          moduleName: item['name']?.toString() ?? 'Без названия',
          description: item['description']?.toString() ?? '',
          cardsCount: item['cardsCount'] ?? 0,
          authorId: item['userId']?.toString() ?? '',
        );
      },
    );
  }

  Widget _emptyState(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Попробуйте другое название',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
