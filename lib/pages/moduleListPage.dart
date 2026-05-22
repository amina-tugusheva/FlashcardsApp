// screens/module_list_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursework/components/module_model.dart'; 
import 'userCardsList.dart'; 
import 'create_module.dart';
import 'package:coursework/services/module_service.dart';


class ModuleListPage extends StatefulWidget {
  @override
  _ModuleListPageState createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> 
    with SingleTickerProviderStateMixin {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final ModuleService _moduleService = ModuleService();

  late TabController _tabController;
  int _currentIndex = 0; // 0=Свои, 1=Сохранённые

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _currentIndex = index),
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: 'Свои'),
            Tab(icon: Icon(Icons.download), text: 'Сохранённые'),
          ],
        ),
      ),
      body: StreamBuilder<List<ModuleModel>>(
        stream: _moduleService.watchUserModules(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(false);
          }

          final allModules = snapshot.data!;
          final ownModules = _moduleService.splitModules(modules: allModules, showSavedOnly: false);
          final savedModules = _moduleService.splitModules(modules: allModules, showSavedOnly: true);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildModulesList(ownModules, showSavedOnly: false),
              _buildModulesList(savedModules, showSavedOnly: true),
            ],
          );
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateModule()),
              ),
              child: const Icon(Icons.add),
              tooltip: 'Создать новый модуль',
            )
          : null,
    );
  }
  // ФУНКЦИЯ РАЗДЕЛЕНИЯ!
  Widget _buildModulesList(List<ModuleModel> modules, {required bool showSavedOnly}) {
    if (modules.isEmpty) {
      return _buildEmptyState(showSavedOnly);
    }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            final isPublic = module.isPublic ?? false;
            final isSaved = module.isSaved ?? false;
            final progress = module.overallProgress.clamp(0.0, 1.0);
            final scheme = Theme.of(context).colorScheme;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              
              // child: Padding(
              //   padding: const EdgeInsets.all(16), 
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           CircleAvatar(
              //             backgroundColor: isPublic 
              //                 ? Theme.of(context).colorScheme.primaryContainer 
              //                 : Theme.of(context).colorScheme.surfaceVariant,
              //             foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              //             child: Text(
              //               '${module.cardsCount ?? 0}',
              //               style: const TextStyle(fontWeight: FontWeight.bold),
              //             ),
              //           ),
              //           SizedBox(width: 12),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   module.name,
              //                   style: Theme.of(context).textTheme.titleMedium,
              //                 ),
              //                 if ((module.description ?? '').isNotEmpty)
              //                   Padding(
              //                     padding: const EdgeInsets.only(top: 4),
              //                     child: Text(
              //                       module.description!,
              //                       style: Theme.of(context)
              //                           .textTheme
              //                           .bodyMedium
              //                           ?.copyWith(fontSize: 14),
              //                       maxLines: 2,
              //                       overflow: TextOverflow.ellipsis,
              //                     ),
              //                   ),
              //               ],
              //             ),
              //           ),

                       
                      
              //         ],
              //       ),
                    
              //       SizedBox(height: 12),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 // Заголовок прогресса
              //                 Text(
              //                   'Пройдено материала',
              //                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                 ),
              //                 SizedBox(height: 4),
              //                 LinearProgressIndicator(
              //                   value: progress,
              //                   backgroundColor: Colors.grey[300],
              //                   valueColor: AlwaysStoppedAnimation(
              //                     progress >= 0.8
              //                         ? scheme.primary
              //                         : progress >= 0.5
              //                             ? scheme.tertiary
              //                             : scheme.secondary,
              //                   ),
              //                   minHeight: 8,
              //                   borderRadius: BorderRadius.circular(4),
              //                 ),
              //                 SizedBox(height: 4),
              //                 
              //                 Row(
              //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       '${(progress * 100).round()}%',
              //                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //                         fontWeight: FontWeight.bold,
              //                         color: scheme.primary,
              //                       ),
              //                     ),
              //                     Text(
              //                       'Box5: ${module.cardsInBox5}/${module.cardsCount}',
              //                       style: Theme.of(context).textTheme.bodySmall,
              //                     ),
              //                   ],
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 12),

              //       Row(
              //         children: [
              //           if (isSaved)
              //         Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             // Тег "Сохранено"
              //             Container(
              //               margin: const EdgeInsets.only(bottom: 4),
              //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //               decoration: BoxDecoration(
              //                 color: Colors.green.withOpacity(0.1),
              //                 borderRadius: BorderRadius.circular(12),
              //               ),
              //               child: const Row(
              //                 mainAxisSize: MainAxisSize.min,
              //                 children: [
              //                   Icon(Icons.download, size: 14, color: Colors.green),
              //                   SizedBox(width: 4),
              //                   Text('Сохранено', style: TextStyle(color: Colors.green, fontSize: 12)),
              //                 ],
              //               ),
              //             ),
              //             //  ИМЯ АВТОРА!
              //             Text(
              //               'Автор: ${module.sourceAuthorName}',
              //               style: TextStyle(
              //                 color: Colors.grey[600],
              //                 fontSize: 12,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ],
              //         ),
                      
                    
              //       // ТЕГ "ПУБЛИЧНЫЙ"
              //       if (isPublic)
              //         Container(
              //           margin: const EdgeInsets.only(top: 4),
              //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //           decoration: BoxDecoration(
              //             color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //           child: Text(
              //             'Публичный',
              //             style: TextStyle(
              //               color: Theme.of(context).colorScheme.primary,
              //               fontSize: 12,
              //             ),
              //           ),
              //         ),

              //         ],
              //       ),
              //       SizedBox(height: 12),
                   
              //     ],
              //   ),
                
              //   ),
                
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                
                leading: CircleAvatar(
                  backgroundColor: isPublic 
                      ? Theme.of(context).colorScheme.primaryContainer 
                      : Theme.of(context).colorScheme.surfaceVariant,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: Text(
                    '${module.cardsCount ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  module.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (module.description?.isNotEmpty == true)
                      // Text(module.description!),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          module.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    SizedBox(height: 12),
                    // ПРОГРЕСС-БАР + %!
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Заголовок прогресса
                              Text(
                                'Пройдено материала',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              // ПРОГРЕСС-БАР!
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color.fromARGB(255, 180, 180, 180),
                                valueColor: AlwaysStoppedAnimation(
                                  progress >= 0.8
                                      ? scheme.primary
                                      : progress >= 0.5
                                          ? scheme.tertiary
                                          : scheme.primaryContainer,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              SizedBox(height: 4),
                              // % + сессии!
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'Box5: ${module.cardsInBox5}/${module.cardsCount}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // ТЕГ "СОХРАНЁНО"
                    if (isSaved)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Тег "Сохранено"
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download, size: 14, color: Colors.green),
                                SizedBox(width: 4),
                                Text('Сохранено', style: TextStyle(color: Colors.green, fontSize: 12)),
                              ],
                            ),
                          ),
                          //  ИМЯ АВТОРА!
                          Text(
                            'Автор: ${module.sourceAuthorName}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                    
                    // ТЕГ "ПУБЛИЧНЫЙ"
                    if (isPublic)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Публичный',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSaved)
                      Icon(
                        isPublic ? Icons.public : Icons.lock,
                        color: isPublic 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    // if (isSaved)
                    //   Icon(Icons.download_done, color: Colors.green, size: 20),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserCardsList(
                      moduleId: module.id,
                      moduleName: module.name,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      
    
  }
  Widget _buildEmptyState(bool showSavedOnly) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(showSavedOnly ? Icons.download : Icons.folder_open, size: 64),
          const SizedBox(height: 16),
          Text(
            showSavedOnly
                ? 'Сохраните модули из чужих профилей'
                : 'Создайте первый модуль!',
          ),
        ],
      ),
    );
  }
}
