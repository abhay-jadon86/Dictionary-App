import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dictionary_app/app_theme.dart';

class RandomWordDice extends StatefulWidget {
  const RandomWordDice({super.key});

  @override
  State<RandomWordDice> createState() => _RandomWordDiceState();
}

class _RandomWordDiceState extends State<RandomWordDice>
    with SingleTickerProviderStateMixin {
  late String apiKey ;
  late AnimationController _controller;
  bool isLoading = false;
  bool showWord = false;
  String currentWord = '';
  String currentDefinition = '';
  List<Map<String, String>> wordHistory = [];
  final Random _random = Random();
  bool isFavorite = false;

  final List<Map<String, String>> _fallbackWords = [
    {'word': 'Serendipity', 'definition': 'The occurrence of events by chance in a happy way'},
    {'word': 'Ephemeral', 'definition': 'Lasting for a very short time'},
    {'word': 'Ubiquitous', 'definition': 'Present everywhere simultaneously'},
    {'word': 'Eloquent', 'definition': 'Fluent or persuasive in speaking or writing'},
    {'word': 'Resilient', 'definition': 'Able to withstand or recover quickly from difficult conditions'},
  ];

  @override
  void initState() {
    apiKey = dotenv.env['WORDNIK_KEY']!;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    super.initState();
  }

  Future<void> fetchRandomWord() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      showWord = false;
      isFavorite = false;
      _controller.repeat();
    });

    try {
      final wordRes = await http.get(
          Uri.parse('https://api.wordnik.com/v4/words.json/randomWord?api_key=$apiKey')
      ).timeout(const Duration(seconds: 5));

      if (wordRes.statusCode == 200) {
        final wordData = json.decode(wordRes.body);
        final word = wordData['word'];

        final defRes = await http.get(
            Uri.parse('https://api.wordnik.com/v4/word.json/$word/definitions?limit=1&api_key=$apiKey')
        ).timeout(const Duration(seconds: 5));

        String definition = "No definition found";
        if (defRes.statusCode == 200) {
          final defList = json.decode(defRes.body);
          if (defList.isNotEmpty && defList[0]['text'] != null) {
            definition = defList[0]['text']
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .replaceAll('&quot;', '"');
          }
        }

        setState(() {
          currentWord = word;
          currentDefinition = definition;
          wordHistory.insert(0, {'word': word, 'definition': definition});
          if (wordHistory.length > 10) wordHistory.removeLast();
        });
      } else {
        _useFallbackWord();
      }
    } catch (e) {
      _useFallbackWord();
    } finally {
      _controller.stop();
      setState(() {
        isLoading = false;
        showWord = true;
      });
      _checkIfFavorite();
    }
  }

  void _useFallbackWord() {
    final randomWord = _fallbackWords[_random.nextInt(_fallbackWords.length)];
    setState(() {
      currentWord = randomWord['word']!;
      currentDefinition = randomWord['definition']!;
      wordHistory.insert(0, {'word': currentWord, 'definition': currentDefinition});
      if (wordHistory.length > 10) wordHistory.removeLast();
    });
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favourites') ?? [];
    setState(() {
      isFavorite = favorites.contains(currentWord);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favourites') ?? [];
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      if (isFavorite) {
        favorites.remove(currentWord);
      } else {
        favorites.add(currentWord);
      }
      isFavorite = !isFavorite;
      prefs.setStringList('favourites', favorites);
    });

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('favourites')
            .doc(user.uid)
            .set({'words': favorites});
      } else {
        print("User not logged in, cannot update Firestore.");
      }
    } catch (e) {
      print('Error updating Firestore: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to favorites!' : 'Removed from favorites',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: "InterTight", color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          "Random Word",
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontSize: width * 0.06,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (showWord)
            IconButton(
              onPressed: _toggleFavorite,
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  if (isFavorite)
                    Icon(
                      Icons.favorite,
                      color: Colors.black,
                      size: (theme.iconTheme.size ?? 24.0) + 2.0,
                    ),
                  Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFFFD700) : theme.iconTheme.color,
                    size: theme.iconTheme.size,
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(width * 0.05),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          child: Text(
                            showWord ? currentWord : '?',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: width * 0.1,
                              fontFamily: "InterTight",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Flexible(
                          child: Text(
                            showWord ? currentDefinition : 'Tap dice to reveal a random word',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: width * 0.045,
                              fontFamily: "InterTight",
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  GestureDetector(
                    onTap: fetchRandomWord,
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                      child: Container(
                        width: width * 0.25,
                        height: width * 0.25,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.casino,
                          size: width * 0.15,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (wordHistory.isNotEmpty)
            Container(
              height: height * 0.3,
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Words",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: width * 0.05,
                      fontFamily: "InterTight",
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Expanded(
                    child: ListView.builder(
                      itemCount: wordHistory.length,
                      itemBuilder: (context, index) {
                        final item = wordHistory[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item['word']!,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: width * 0.045,
                              fontFamily: "InterTight",
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            item['definition']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: width * 0.035,
                              fontFamily: "InterTight",
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              currentWord = item['word']!;
                              currentDefinition = item['definition']!;
                              showWord = true;
                            });
                            _checkIfFavorite();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
