import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursework/services/module_service.dart';
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
  final ModuleService _moduleService = ModuleService();

  bool isPublic = true;
  bool isLoading = false;  // Антидублирование
  
  // Список карточек
  // List<Map<String, String>> cards = [];
  List<TextEditingController> termControllers = [];
  List<TextEditingController> definitionControllers = [];

@override
  void initState() {
    super.initState();  
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    for (final controller in termControllers) {
      controller.dispose();
    }
    for (final controller in definitionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // загрузка существующих карточек при редактировании 
  Future<void> _loadModuleData() async {
    try {
      final data = await _moduleService.loadModule(currentUser.uid, widget.moduleId!);
      if (data == null) return;

      if (!mounted) return;
      setState(() {
        nameController.text = data['name'] ?? '';
        descriptionController.text = data['description'] ?? '';
        isPublic = data['isPublic'] ?? true;

        termControllers = [];
        definitionControllers = [];

        final cards = (data['cards'] as List).cast<Map<String, dynamic>>();
        for (final card in cards) {
          termControllers.add(TextEditingController(text: card['term'] ?? ''));
          definitionControllers.add(TextEditingController(text: card['definition'] ?? ''));
        }

        if (termControllers.isEmpty) {
          _addCardFields();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
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
    final validCards = <Map<String, String>>[];

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
    if (isLoading) return;

    final name = nameController.text.trim();
    final cards = getValidCards();

    if (name.isEmpty || cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте название и хотя бы 1 карточку')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.moduleId == null) {
        await _moduleService.createModule(
          userId: currentUser.uid,
          name: name,
          description: descriptionController.text.trim(),
          isPublic: isPublic,
          cards: cards,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Модуль создан с ${cards.length} карточками!')),
        );
      } else {
        await _moduleService.updateModule(
          userId: currentUser.uid,
          moduleId: widget.moduleId!,
          name: name,
          description: descriptionController.text.trim(),
          isPublic: isPublic,
          cards: cards,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Модуль сохранен')),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
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
                      ],
                    ),
                  );
                }),
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
        ],
      ),
    );
  }

  // @override
  // void dispose() {
  //   nameController.dispose();
  //   descriptionController.dispose();
  //   for (var controller in termControllers) controller.dispose();
  //   for (var controller in definitionControllers) controller.dispose();
  //   super.dispose();
  // }
}

