// страница не используется 
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'userCardsList.dart';

// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:file_picker/file_picker.dart';


// class AutoGenerateCardsScreen extends StatefulWidget {
//   final String moduleId;

//   const AutoGenerateCardsScreen({Key? key, required this.moduleId}) : super(key: key);

//   @override
//   _AutoGenerateCardsScreenState createState() => _AutoGenerateCardsScreenState();
// }
// class _AutoGenerateCardsScreenState extends State<AutoGenerateCardsScreen> {
//   final TextEditingController _textController = TextEditingController();
//   PlatformFile? _pickedFile;
//   String? _fileName;
//   bool _isLoading = false;
//   List<CardModel> _generatedCards = [];

//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowedExtensions: ['txt', 'pdf', 'docx'],
//       type: FileType.custom,
//     );
//     if (result != null) {
//       setState(() {
//         _pickedFile = result.files.first;
//         _fileName = _pickedFile!.name;
//         _textController.clear(); // Очистить текст, если выбрали файл
//       });
//     }
//   }

//   Future<void> _generateCards() async {
//     if (_pickedFile == null && _textController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Введите текст или выберите файл')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _generatedCards = [];
//     });

//     try {
//       Uri uri = Uri.parse('http://10.0.2.2:8000/generate_flashcards'); // для iOS эмулятора http://localhost:8000/generate_flashcards

//       http.Response response;
//       if (_pickedFile != null) {
//         var request = http.MultipartRequest('POST', uri);
//         request.files.add(http.MultipartFile.fromBytes(
//           'file',
//           _pickedFile!.bytes!,
//           filename: _pickedFile!.name,
//         ));
//         var streamedResponse = await request.send();
//         response = await http.Response.fromStream(streamedResponse);
//       } else {
//         response = await http.post(
//           uri,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'text': _textController.text.trim(),
//             'max_cards': 20,
//           }),
//         );
//       }

//       if (response.statusCode == 200) {
//         List<dynamic> jsonList = jsonDecode(response.body);
//         setState(() {
//           _generatedCards = jsonList.map((json) => CardModel(
//                 term: json['term'] ?? '',
//                 definition: json['definition'] ?? '',
//                 id: '', // id будет создан при сохранении
//                 box: 1, // начальный уровень Лейтнера
//                 nextReview: null, // без даты повторения по умолчанию
//               )).toList();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Ошибка генерации: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Произошла ошибка: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveCards() async {
//     if (_generatedCards.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Нет карточек для сохранения')),
//       );
//       return;
//     }

//     final currentUser = FirebaseAuth.instance.currentUser!;
//     final batch = FirebaseFirestore.instance.batch();
//     final collectionRef = FirebaseFirestore.instance
//         .collection('Users')
//         .doc(currentUser.uid)
//         .collection('modules')
//         .doc(widget.moduleId)
//         .collection('user_cards');

//     for (var card in _generatedCards) {
//       var newDoc = collectionRef.doc();
//       batch.set(newDoc, {
//         'term': card.term,
//         'definition': card.definition,
//         'box': card.box,
//         'nextReview': card.nextReview,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }

//     await batch.commit();

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Карточки успешно сохранены')),
//     );

//     setState(() {
//       _generatedCards.clear();
//       _fileName = null;
//       _pickedFile = null;
//       _textController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Автоматическая генерация карточек'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _textController,
//               maxLines: 5,
//               decoration: const InputDecoration(
//                 labelText: 'Введите текст для генерации',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (_) {
//                 if (_pickedFile != null) {
//                   setState(() {
//                     _pickedFile = null;
//                     _fileName = null;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _pickFile,
//                   icon: const Icon(Icons.attach_file),
//                   label: const Text('Выбрать файл'),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     _fileName ?? 'Файл не выбран',
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _generateCards,
//               child: _isLoading
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                     )
//                   : const Text('Сгенерировать карточки'),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: _generatedCards.isEmpty
//                   ? const Center(child: Text('Сгенерированные карточки появятся здесь'))
//                   : ListView.builder(
//                       itemCount: _generatedCards.length,
//                       itemBuilder: (context, index) {
//                         final card = _generatedCards[index];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             title: Text(card.term),
//                             subtitle: Text(card.definition),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             if (_generatedCards.isNotEmpty)
//               ElevatedButton.icon(
//                 onPressed: _saveCards,
//                 icon: const Icon(Icons.save),
//                 label: const Text('Сохранить карточки'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'userCardsList.dart';

// Модель карточки
class CardModel {
  final String term;
  final String definition;

  CardModel({required this.term, required this.definition});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      term: json['term'],
      definition: json['definition'],
    );
  }
}

class AutoGenerateCardsScreen extends StatefulWidget {
  final String moduleId;
  const AutoGenerateCardsScreen({Key? key, required this.moduleId}) : super(key: key);

  @override
  _AutoGenerateCardsScreenState createState() => _AutoGenerateCardsScreenState();
}

class _AutoGenerateCardsScreenState extends State<AutoGenerateCardsScreen> {
  final TextEditingController _textController = TextEditingController();
  List<CardModel> _generatedCards = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _generateCards() async {
    final inputText = _textController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _error = "Введите текст для генерации карточек";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _generatedCards = [];
    });

    // try {
    //   final url = Uri.parse('http://10.0.2.2:8000/generate-cards'); // Замените на адрес вашего API
    //   final response = await http.post(url,
    //       headers: {'Content-Type': 'application/json'},
    //       body: jsonEncode({'text': inputText}));

    //   if (response.statusCode == 200) {
    //     final List<dynamic> data = jsonDecode(response.body);
    //     setState(() {
    //       _generatedCards = data.map((e) => CardModel.fromJson(e)).toList();
    //     });
    //   } else {
    //     setState(() {
    //       _error = 'Ошибка сервера: ${response.statusCode}';
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     _error = 'Ошибка соединения: $e';
    //   });
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  Widget _buildCardItem(CardModel card) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(card.term, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(card.definition),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Генерация карточек'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Введите текст для генерации карточек',
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateCards,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Сгенерировать'),
            ),
            SizedBox(height: 12),
            _error != null
                ? Text(_error!, style: TextStyle(color: Colors.red))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _generatedCards.length,
                      itemBuilder: (context, index) {
                        return _buildCardItem(_generatedCards[index]);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}