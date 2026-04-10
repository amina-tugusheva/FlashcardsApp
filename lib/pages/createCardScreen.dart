import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;


final currentUser = FirebaseAuth.instance.currentUser!;

class CreateCardScreen extends StatefulWidget {
  final String moduleId; // ID модуля, к которому привязываем карточку

  const CreateCardScreen({Key? key, required this.moduleId}) : super(key: key);

  @override
  _CreateCardScreenState createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final TextEditingController termController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!; // получаем текущего пользователя

  // Переменные для изображения
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Выбор изображения из галереи
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выбора изображения: $e')),
      );
    }
  }
  // Удаление изображения
  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  // Загрузка изображения в Firebase Storage
  Future<String?> _uploadImage(String cardId) async {
    if (_imageFile == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      // final fileName = path.basename(_imageFile!.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_imageFile!.path)}';
      final userId = currentUser.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cards/$userId/${widget.moduleId}/$cardId/$fileName');

      final uploadTask = await storageRef.putFile(_imageFile!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      print('Изображение загружено: $imageUrl');
      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки изображения: $e')),
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> saveCard() async {
    final term = termController.text.trim();
    final definition = definitionController.text.trim();
    final userId = currentUser.uid;

    if (term.isEmpty || definition.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

  //   // await FirebaseFirestore.instance
  //   // .collection('Users')
  //   // .doc(currentUser.uid)
  //   // .collection('modules')
  //   // .doc(widget.moduleId)                 
  //   // .collection('user_cards')
  //   // .add
  //   // ({
  //   //   'term': term,
  //   //   'definition': definition,
  //   //   'userId': userId,
  //   //   'moduleId': widget.moduleId, //Привязка к модулю
  //   //   'createdAt': FieldValue.serverTimestamp(),
  //   // });

  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   SnackBar(content: Text('Карточка сохранена')),
  //   // );
  //   // termController.clear();
  //   // definitionController.clear();
  //   // Создаем карточку без изображения сначала
  //   final cardRef = await FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(currentUser.uid)
  //       .collection('modules')
  //       .doc(widget.moduleId)
  //       .collection('user_cards')
  //       .add({
  //     'term': term,
  //     'definition': definition,
  //     'userId': userId,
  //     'moduleId': widget.moduleId,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'imageUrl': '', // Пока пустая строка
  //   });

  //   // Если есть изображение, загружаем его
  //   if (_imageFile != null) {
  //     final imageUrl = await _uploadImage(cardRef.id);
  //     if (imageUrl != null) {
  //       await cardRef.update({'imageUrl': imageUrl});
  //     }
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Карточка сохранена')),
  //   );
    
  //   // Очистка формы
  //   termController.clear();
  //   definitionController.clear();
  //   setState(() {
  //     _imageFile = null;
  //   });
  // }
  setState(() {
      _isUploading = true;
    });

    try {
      // 1. Создаем карточку БЕЗ изображения
      final cardRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('user_cards')
          .add({
        'term': term,
        'definition': definition,
        'userId': userId,
        'moduleId': widget.moduleId,
        'imageUrl': '',  // Пока пусто
        'box': 1,        // Начальный бокс Лейтнера
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Если есть изображение - загружаем и обновляем карточку
      if (_imageFile != null) {
        final imageUrl = await _uploadImage(cardRef.id);
        if (imageUrl != null) {
          await cardRef.update({'imageUrl': imageUrl});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Карточка сохранена${_imageFile != null ? ' с изображением' : ''}'
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Очистка формы
      termController.clear();
      definitionController.clear();
      setState(() {
        _imageFile = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final hasImage = _imageFile != null;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Создать карточку')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: termController,
              decoration: InputDecoration(
                labelText: 'Термин',
                border: OutlineInputBorder(),
                ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: definitionController,
              decoration: InputDecoration(
                labelText: 'Определение',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),

            // // Разделитель для изображения
            //   Divider(),
            //   SizedBox(height: 16),
            //   Text('Изображение (необязательно)', 
            //        style: Theme.of(context).textTheme.titleMedium),
            //   SizedBox(height: 16),
            // Кнопка выбора изображения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: Icon(Icons.photo_library),
                  label: Text(_imageFile == null ? 'Добавить изображение' : 'Изменить изображение'),
                ),
              ),

              // // Превью изображения
              // Container(
              //   height: 200,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color: Colors.grey[200],
              //     border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: _imageFile != null
              //       ? ClipRRect(
              //           borderRadius: BorderRadius.circular(8),
              //           child: Image.file(
              //             _imageFile!,
              //             fit: BoxFit.cover,
              //           ),
              //         )
              //       : Icon(Icons.image, size: 50, color: Colors.grey),
              // ),

              // Превью изображения
              if (hasImage) ...[
                SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: _removeImage,
                        icon: Icon(Icons.close, color: Colors.red, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Изображение будет загружено в Firebase Storage',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 24),

              // // Кнопка выбора изображения
              // ElevatedButton.icon(
              //   onPressed: _isUploading ? null : _pickImage,
              //   icon: Icon(Icons.photo_library),
              //   label: Text(_imageFile == null ? 'Выбрать изображение' : 'Сменить изображение'),
              // ),
              // SizedBox(height: 24),

            // ElevatedButton(
            //   onPressed: saveCard,
            //   child: Text('Сохранить'),
            // ),
            // // Кнопка сохранения
            //   SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: _isUploading ? null : saveCard,
            //       child: _isUploading
            //           ? Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 SizedBox(
            //                   width: 20,
            //                   height: 20,
            //                   child: CircularProgressIndicator(strokeWidth: 2),
            //                 ),
            //                 SizedBox(width: 12),
            //                 Text('Сохранение...'),
            //               ],
            //             )
            //           : Text('Сохранить карточку'),
            //     ),
            //   ),
            // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isUploading ? null : saveCard,
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                            ),
                            SizedBox(width: 12),
                            Text('Сохранение...'),
                          ],
                        )
                      : Text('Сохранить карточку', style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    termController.dispose();
    definitionController.dispose();
    super.dispose();
  }
}
