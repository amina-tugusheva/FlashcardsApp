// screens/module_list_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursework/components/module_model.dart'; 
import 'userCardsList.dart'; 
import 'create_module.dart';

import 'createCardScreen.dart'; 
import 'createModuleScreen.dart'; 

class ModuleListPage extends StatefulWidget {
  @override
  _ModuleListPageState createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> 
    with SingleTickerProviderStateMixin {
  final currentUser = FirebaseAuth.instance.currentUser!;

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
        // title: const Text('Мои модули'),
      bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _currentIndex = index),
          tabs: [
            Tab(icon: Icon(Icons.folder), text: 'Свои'),
            Tab(icon: Icon(Icons.download), text: 'Сохранённые'),
          ],
        ),
      ),
      // TabBarView — 2 ВКЛАДКИ!
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildModulesList(showSavedOnly: false), // СВОИ
          _buildModulesList(showSavedOnly: true),  // СОХРАНЁННЫЕ
        ],
      ),
      
      // FAB ТОЛЬКО в "Свои"
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateModule()),
              ),
              child: Icon(Icons.add),
              tooltip: 'Создать новый модуль',
            )
          : null,
      
      
      
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: FirebaseFirestore.instance
      //       // .collection('modules')
      //       // // .where('email', isEqualTo: currentUser.email)
      //       // .where('userId', isEqualTo: currentUser.uid)
      //       .collection('Users')
      //       .doc(currentUser.uid)
      //       .collection('modules')

      //       .orderBy('createdAt', descending: true)
      //       .snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     }

      //     if (snapshot.hasError) {
      //       return Center(child: 
      //       Text('Ошибка загрузки данных: ${snapshot.error}')
            
      //       );
      //     }
      //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      //       return Center(child: Text('Модулей пока нет. Создайте первый!${currentUser.uid}'));
      //     }
          

      //     final modules = snapshot.data!.docs.map((doc) => ModuleModel.fromFirestore(doc)).toList();

      //     return ListView.builder(
      //       padding: const EdgeInsets.all(16),
      //       itemCount: modules.length,
      //       itemBuilder: (context, index) {
      //         final module = modules[index];

      //         final isPublic = module.isPublic ?? false;

      //         return Card(
      //           margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      //           child: ListTile(
      //             contentPadding: const EdgeInsets.all(16),
      //             leading: CircleAvatar(
      //               backgroundColor: isPublic 
      //                   ? Theme.of(context).colorScheme.primaryContainer 
      //                   : Theme.of(context).colorScheme.surfaceVariant,
      //               foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      //               child: Text(
      //                 '${module.cardsCount ?? 0}',
      //                 style: const TextStyle(fontWeight: FontWeight.bold),
      //               ),
      //             ),
      //             title: Text(
      //               module.name,
      //               style: Theme.of(context).textTheme.titleMedium,
      //             ),
      //             subtitle: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 if (module.description?.isNotEmpty == true)
      //                   Text(module.description!),
      //                 // Text('Карточек: ${module.cardsCount ?? 0}'),
      //                 if (isPublic)
      //                   Container(
      //                     margin: const EdgeInsets.only(top: 4),
      //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      //                     decoration: BoxDecoration(
      //                       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: Text(
      //                       'Публичный',
      //                       style: TextStyle(
      //                         color: Theme.of(context).colorScheme.primary,
      //                         fontSize: 12,
      //                       ),
      //                     ),
      //                   ),
      //               ],
      //             ),
      //             trailing: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 Icon(
      //                   isPublic ? Icons.public : Icons.lock,
      //                   color: isPublic 
      //                       ? Theme.of(context).colorScheme.primary 
      //                       : Theme.of(context).colorScheme.onSurfaceVariant,
      //                   size: 20,
      //                 ),
      //                 // IconButton(
      //                 //   icon: const Icon(Icons.delete, color: Colors.red),
      //                 //   tooltip: 'Удалить модуль',
      //                 //   onPressed: () async {
      //                 //     final shouldDelete = await showDialog<bool>(
      //                 //       context: context,
      //                 //       builder: (context) => AlertDialog(
      //                 //         title: const Text('Удалить модуль?'),
      //                 //         content: const Text(
      //                 //           'Все карточки внутри модуля тоже будут удалены. Продолжить?'
      //                 //         ),
      //                 //         actions: [
      //                 //           TextButton(
      //                 //             child: const Text('Отмена'),
      //                 //             onPressed: () => Navigator.pop(context, false),
      //                 //           ),
      //                 //           TextButton(
      //                 //             child: const Text('Удалить', style: TextStyle(color: Colors.red)),
      //                 //             onPressed: () => Navigator.pop(context, true),
      //                 //           ),
      //                 //         ],
      //                 //       ),
      //                 //     );
                          
      //                 //     if (shouldDelete == true) {
      //                 //       final moduleRef = FirebaseFirestore.instance
      //                 //           .collection('Users')
      //                 //           .doc(currentUser.uid)
      //                 //           .collection('modules')
      //                 //           .doc(module.id);
                            
      //                 //       // Удалить карточки
      //                 //       final cardsSnapshot = await moduleRef.collection('user_cards').get();
      //                 //       for (final card in cardsSnapshot.docs) {
      //                 //         await card.reference.delete();
      //                 //       }
      //                 //       // Удалить модуль
      //                 //       await moduleRef.delete();
                            
      //                 //       // if (mounted) {
      //                 //       //   ScaffoldMessenger.of(context).showSnackBar(
      //                 //       //     const SnackBar(content: Text('Модуль удалён')),
      //                 //       //   );
      //                 //       // }
      //                 //     }
      //                 //   },
      //                 // ),
      //               ],
      //             ),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => UserCardsList(
      //                     moduleId: module.id,
      //                     moduleName: module.name,
      //                   ),
      //                 ),
      //               );
      //             },
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Переход на экран создания нового модуля
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => CreateModule()),
      //     );
      //   },
      //   child: Icon(Icons.add),
      //   tooltip: 'Создать новый модуль',
      // ),
    );
  }
  // ФУНКЦИЯ РАЗДЕЛЕНИЯ!
  Widget _buildModulesList({required bool showSavedOnly}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(showSavedOnly ? Icons.download : Icons.folder_open, size: 64),
                SizedBox(height: 16),
                Text(showSavedOnly 
                    ? 'Сохраните модули из чужих профилей' 
                    : 'Создайте первый модуль!'),
              ],
            ),
          );
        }

        // ФИЛЬТР ПО isSaved!
        final modules = snapshot.data!.docs
            .map((doc) => ModuleModel.fromFirestore(doc))
            .where((module) {
              final isSavedModule = module.isSaved ?? false;
              return showSavedOnly ? isSavedModule : !isSavedModule;
            })
            .toList();

        if (modules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(showSavedOnly ? Icons.star_border : Icons.add, size: 64),
                SizedBox(height: 16),
                Text(showSavedOnly 
                    ? 'Сохранённых модулей нет' 
                    : 'Модулей пока нет'),
              ],
            ),
          );
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
              //       // ПРОГРЕСС-БАР + %!
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
              //                 // ✅ ПРОГРЕСС-БАР!
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
              //                 // ✅ % + сессии!
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
                              // ✅ ПРОГРЕСС-БАР!
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
                              // ✅ % + сессии!
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
      },
    );
  }
}
