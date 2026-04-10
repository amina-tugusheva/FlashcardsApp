import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateModule extends StatefulWidget {
  final String? moduleId;  // null = создание, ID = редактирование
  final String? moduleName;
  const CreateModule({super.key, this.moduleId, this.moduleName});

  @override
  _CreateModuleState createState() => _CreateModuleState();
}

class _CreateModuleState extends State<CreateModule> {
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController descriptionController = TextEditingController();
  late final TextEditingController nameController;  // late
  late final TextEditingController descriptionController;
  final currentUser = FirebaseAuth.instance.currentUser!;
  
  bool isPublic = true;
  bool isLoading = false;  // Антидублирование!
  
  // Список карточек
  // List<Map<String, String>> cards = [];
  List<TextEditingController> termControllers = [];
  List<TextEditingController> definitionControllers = [];

@override
  void initState() {
    super.initState();  // ПЕРВЫМ!
    nameController = TextEditingController(text: widget.moduleName ?? '');
    descriptionController = TextEditingController();

    super.initState();
    // Добавляем первое поле карточки автоматически
    if (widget.moduleId != null) {
      _loadModuleData();  // Загружаем для редактирования
    } else {
      _addCardFields();   // Создание — добавляем пустое поле
    }
  }

  // загрузка существующих карточек при редактировании 
  Future<void> _loadModuleData() async {
    try {
      final moduleDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      if (moduleDoc.exists) {
        final data = moduleDoc.data()!;

        nameController.text = data['name'] ?? widget.moduleName ?? '';
        descriptionController.text = data['description'] ?? '';
        isPublic = data['isPublic'] ?? true; 

        // Загружаем карточки
        final cardsSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('modules')
            .doc(widget.moduleId)
            .collection('user_cards')
            .orderBy('createdAt')
            .get();

        if (mounted) {
          setState(() {
            for (var doc in cardsSnapshot.docs) {
              final cardData = doc.data() as Map<String, dynamic>;
              termControllers.add(TextEditingController(text: cardData['term'] ?? ''));
              definitionControllers.add(TextEditingController(text: cardData['definition'] ?? ''));
            }
            if (termControllers.isEmpty) _addCardFields();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
    if (mounted) setState(() {});  // Refresh UI
  }

  void _addCardFields() {
    setState(() {
      termControllers.add(TextEditingController());
      definitionControllers.add(TextEditingController());
    });
  }

  void _removeCardFields(int index) {
    setState(() {
      termControllers[index].dispose();
      definitionControllers[index].dispose();
      termControllers.removeAt(index);
      definitionControllers.removeAt(index);
    });
  }

  

  List<Map<String, String>> getValidCards() {
    final termsSet = <String>{};  //  Антидубли!
    List<Map<String, String>> validCards = [];
    for (int i = 0; i < termControllers.length; i++) {
      final term = termControllers[i].text.trim();
      final definition = definitionControllers[i].text.trim();
      if (term.isNotEmpty && definition.isNotEmpty) {
        validCards.add({
          'term': term,
          'definition': definition,
        });
      }
    }
    return validCards;
  }

  Future<void> saveModule() async {
    if (isLoading) return;  // Блокировка дублей!
    if (widget.moduleId == null) {
      // СОЗДАНИЕ — add новый модуль
      final name = nameController.text.trim();
      final validCards = getValidCards();
      
      if (name.isEmpty || validCards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Добавьте название и хотя бы 1 карточку')),
        );
        return;
      }
      setState(() => isLoading = true);  // Spinner!

      try {
        final moduleRef = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('modules')
            .add({
          'name': name,
          'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
          'userId': currentUser.uid,
          'isPublic': isPublic,
          'cardsCount': validCards.length,
          'testSessions': 0,     //  Прогресс!
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        

        final batch = FirebaseFirestore.instance.batch();
        for (var card in validCards) {
          final cardRef = FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .collection('modules')
              .doc(moduleRef.id)
              .collection('user_cards')
              .doc();
          batch.set(cardRef, {
            'term': card['term']!,
            'definition': card['definition']!,
            'userId': currentUser.uid,
            'moduleId': moduleRef.id,
            'imageUrl': '',
            'box': 1,
            'correct_count': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Модуль создан с ${validCards.length} карточками!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } else {
      //РЕДАКТИРОВАНИЕ — batch update 
      final name = nameController.text.trim();
      final cards = getValidCards();
      if (name.isEmpty || cards.isEmpty) return;

      try {
        final batch = FirebaseFirestore.instance.batch();

        // Обновляем модуль
        batch.update(
          FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .collection('modules')
              .doc(widget.moduleId),
          {
            'name': name,
            'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
            'isPublic': isPublic,
            'cardsCount': cards.length,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
        );

        // Удаляем старые карточки
        final oldCards = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .collection('modules')
            .doc(widget.moduleId)
            .collection('user_cards')
            .get();
        for (var doc in oldCards.docs) batch.delete(doc.reference);

        // Создаем новые карточки
        for (var card in cards) {
          final newCardRef = FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .collection('modules')
              .doc(widget.moduleId)
              .collection('user_cards')
              .doc();
          batch.set(newCardRef, {
            'term': card['term'],
            'definition': card['definition'],
            'userId': currentUser.uid,
            'moduleId': widget.moduleId,
            'imageUrl': '',
            'box': 1,
            'correct_count': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Модуль сохранен')));
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      } finally {
      if (mounted) setState(() => isLoading = false);  //  Сброс!
      }
    }
    
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final validCards = getValidCards();

    final title = widget.moduleId == null ? 'Создать модуль' : 'Редактировать';

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // title: Text('Создать модуль'),
        // title: Text(
        //   title,
        //   style: TextStyle(
                  
        //     fontSize: 16,
        //   ),
        // ),
        
      actions: [
          
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: TextButton(
              // onPressed: validCards.isNotEmpty ? _showPrivacyDialog : null,
              onPressed: saveModule,
              child: Text(
                '${widget.moduleId == null ? 'Создать' : 'Сохранить'} ',
                style: TextStyle(
                  color: validCards.isNotEmpty ? colors.onPrimary : Colors.grey,
                  // fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Название модуля'),
                ),
                
                // Описание
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Описание'),
                ),

                Row(
                  children: [
                    Switch(
                      value: isPublic,
                      onChanged: (v) => setState(() => isPublic = v),
                    ),
                    Text('Сделать модуль публичным'),
                  ],
                ),
                SizedBox(height: 30),
                Text('${termControllers.length} карточек', 
                     style: theme.textTheme.titleMedium),
                SizedBox(height: 10),

                ...termControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:EdgeInsets.all(16),
                          decoration: BoxDecoration(
                          // color: Theme.of(context).colorScheme.primaryContainer,
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          // border: Border.all(color: Colors.grey.shade200),
                          
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Карточка ${index + 1}', 
                                    style: theme.textTheme.titleSmall),
                                if (termControllers.length > 1)
                                  IconButton(
                                    onPressed: () => _removeCardFields(index),
                                    icon: Icon(Icons.close),
                                  ),
                              ],
                            ),
                            // Text('Карточки:', style: theme.textTheme.titleMedium),
                            TextField(
                              controller: termControllers[index],
                              decoration: InputDecoration(labelText: 'Термин'),
                            ),
                            TextField(
                              controller: definitionControllers[index],
                              decoration: InputDecoration(labelText: 'Определение'),
                              
                            ),

                          ],
                        ),

                        ),

                        // Номер карточки и кнопка удаления
                        
                        
                      ],
                    ),
                  );
                }),

                // Форма новой карточки
                
                
                SizedBox(height: 20),
                IconButton(
                  onPressed: _addCardFields,
                  icon: Icon(Icons.add, size: 40, color: colors.primary),
                  tooltip: 'Добавить карточку',
                ),

                SizedBox(height: 30),

              ],
            ),
          ),

          // Фиксированная нижняя панель
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     // color: Colors.white,
          //     padding: EdgeInsets.all(20),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
                  
          //         ElevatedButton(
          //           onPressed: saveModule,
          //           child: Text(isPublic ? 'Создать публичный' : 'Создать приватный'),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    for (var controller in termControllers) controller.dispose();
    for (var controller in definitionControllers) controller.dispose();
    super.dispose();
  }
}

