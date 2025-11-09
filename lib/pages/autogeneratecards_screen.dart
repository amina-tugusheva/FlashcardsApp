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
