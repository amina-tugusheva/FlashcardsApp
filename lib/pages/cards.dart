import 'package:flutter/material.dart';
import 'userCardsList.dart';
import 'moduleListPage.dart';
import 'test_history_page.dart';
import 'test_statistic_page.dart';
import 'package:coursework/services/card_service.dart';

class CardsPage extends StatefulWidget {
  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final CardsService _cardsService = CardsService();

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
      final modules = await _cardsService.loadPopularModules();
      if (!mounted) return;
      setState(() {
        popularModules = modules;
        isLoadingPopular = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки популярных модулей: $e');
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
                    // backgroundColor: Theme.of(context).colorScheme.primary,  
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: 
                Column(
                  children: [
                    Row(
                      children: [
                        
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.history,
                            label: 'История',
                            onTap: _goToHistory,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.bar_chart,
                            label: 'Статистика',
                            onTap: _goToStats,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

              // const SizedBox(height: 32),
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
  Widget _ActionTile({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {

  return ElevatedButton(
    // borderRadius: BorderRadius.circular(16),
    onPressed: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        // color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
  void _goToHistory() => Navigator.push(context, MaterialPageRoute(builder: (_) => TestHistoryPage()));
  void _goToStats() => Navigator.push(context, MaterialPageRoute(builder: (_) => UserStatisticsPage()));

}
