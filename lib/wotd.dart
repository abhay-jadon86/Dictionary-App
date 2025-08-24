import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WordOfTheDayService {

  Future<Map<String, String>> getWordOfTheDay() async {
    final String apiKey = dotenv.env['WORDNIK_KEY']!;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString('word_date');
    final savedWord = prefs.getString('word');
    final savedDefinition = prefs.getString('definition');

    if (savedDate == today && savedWord != null && savedDefinition != null) {
      return {
        'word': savedWord,
        'definition': savedDefinition,
      };
    }

    final wordResponse = await http.get(
      Uri.parse('https://api.wordnik.com/v4/words.json/wordOfTheDay?api_key=$apiKey'),
    );

    if (wordResponse.statusCode == 200) {
      final data = json.decode(wordResponse.body);
      final word = data['word'];
      final definition = data['definitions'][0]['text'];

      await prefs.setString('word_date', today);
      await prefs.setString('word', word);
      await prefs.setString('definition', definition);

      return {
        'word': word,
        'definition': definition,
      };
    } else {
      return {
        'word': 'Serendipity',
        'definition': 'The occurrence of events by chance in a happy or beneficial way.',
      };
    }
  }
}
