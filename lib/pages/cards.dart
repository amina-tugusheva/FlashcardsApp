import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userCardsList.dart';
import 'moduleListPage.dart';

class CardsPage extends StatefulWidget {
  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  List<Map<String, dynamic>> popularModules = [];
  bool isLoadingPopular = true;
  
  @override
  void initState() {
    super.initState();
    _loadPopularModules();
  }


  Future<void> _loadPopularModules() async {
    setState(() => isLoadingPopular = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('modules')
          .where('isPublic', isEqualTo: true)
          .orderBy('savesCount', descending: true)  // По сохранениям
          .limit(10)
          .get();

      print('ТОП МОДУЛИ ПО СОХРАНЕНИЯМ (${snapshot.docs.length}):');
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data() as Map<String, dynamic>;
        print('  #${i+1}: ${data['name']} | ${data['savesCount'] ?? 0} сохранений');
        print('автор: ${doc.reference.parent.parent!.id}');
      }

      final modules = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Без названия',
          'savesCount': data['savesCount'] ?? 0,  
          'cardsCount': data['cardsCount'] ?? 0,
          'description': data['description']?.toString() ?? '',
          'userId': doc.reference.parent.parent!.id,
        };
      }).toList();

      // if (mounted) {
        // setState(() {
        //   popularModules = modules;
        //   isLoadingPopular = false;
        // });
      // }
      if (snapshot.docs.isNotEmpty) {
      
      popularModules = modules;
      isLoadingPopular = false;
      // popularModules = snapshot.docs.map(_parseModule).toList();
    } else {
      print('Нет популярных, показываем рекомендуемый');
      popularModules = [
        {
          'id': 'Uz9dtY8GeVMXaNnMWvWy',
          'name': 'лексика для экзамена',
          'savesCount': 0,
          'cardsCount': 20,
          'description': 'подготовка к экзамену по английскому',
          'userId': 'H1dluCmhKjMIJxstKK4iy8b7U0L2',
          'isFeatured': true,  
        },
      ];
    }

    if (mounted) {
      setState(() => isLoadingPopular = false);
    }
    } catch (e) {
      print('Ошибка загрузки популярных модулей: $e');
      if (mounted) {
        setState(() => isLoadingPopular = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Text(
              'Мои модули',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                // border: Border.all(
                //   color: Theme.of(context).colorScheme.primary,
                //   width: 2,
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.folder_special,
                    size: 28,  //
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Мои модули',  // 
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,  
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,  
                    shadowColor: Colors.black26,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleListPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // ПОПУЛЯРНЫЕ МОДУЛИ
            Text(
              'Популярные модули',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),

            // Загрузка / Пусто / Список
            if (isLoadingPopular)
              const LinearProgressIndicator()
            else if (popularModules.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.trending_up, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Популярных модулей пока нет',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: _loadPopularModules,
                        child: const Text('Обновить'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,  
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularModules.length,
                  itemBuilder: (context, index) {
                    final module = popularModules[index];
                    return Container(
                      width: 220, 
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserCardsList(
                                  moduleId: module['id']?.toString() ?? 'unknown',
                                  moduleName: module['name']?.toString() ?? 'Без названия',
                                  authorId: module['userId']?.toString() ?? '',
                                  isPublicStudy: true,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star, 
                                      // color: Colors.red, 
                                      size: 20
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${module['savesCount'] ?? 0}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        // color: Colors.red[700],
                                      ),
                                    ),
                                    const Text(
                                      ' сохранений',
                                      style: TextStyle(
                                        fontSize: 12, 
                                        // color: Colors.grey[600]
                                        ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Название
                                Text(
                                  module['name']?.toString() ?? 'Без названия',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                
                                // Описание
                                Expanded(
                                  child: Text(
                                    module['description']?.toString() ?? '',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${module['cardsCount'] ?? 0} карточек',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
