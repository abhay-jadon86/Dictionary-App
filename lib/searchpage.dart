import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dictionary_app/search_history.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import 'package:dictionary_app/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dictionary_app/synonymspage.dart';
import 'package:dictionary_app/favouritespage.dart';

class WordSearchPage extends StatefulWidget {
  final String? initialWord;
  const WordSearchPage({super.key, this.initialWord});

  @override
  State<WordSearchPage> createState() => _WordSearchPageState();
}

class _WordSearchPageState extends State<WordSearchPage> {
  late String merriamWebsterApiKey;

  late String wordnikApiKey;

  late FlutterTts flutterTts;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    merriamWebsterApiKey = dotenv.env['MERRIAM_KEY']!;
    wordnikApiKey = dotenv.env['WORDNIK_KEY']!;
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();

    if (widget.initialWord != null && widget.initialWord!.isNotEmpty) {
      _controller.text = widget.initialWord!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  Future<void> _performSearch() async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
      searchedWord = _controller.text.trim();
      isLoading = true;
      error = null;
      definitions = [];
      exampleSentences = [];
      usedWordnikAsFallback = false;
    });

    if (searchedWord.isEmpty) {
      setState(() {
        isLoading = false;
        _isSearching = false; // Reset flag
        error = "Please enter a word";
      });
      return;
    }

    SearchHistory.add(searchedWord);

    try {
      definitions = await getMerriamWebsterDefinitions(searchedWord);
      if (definitions.isEmpty) {
        definitions = await getWordnikDefinitions(searchedWord);
        usedWordnikAsFallback = true;
      }

      if (definitions.isEmpty) {
        setState(() {
          isLoading = false;
          error = "No definitions found for '$searchedWord'";
        });
        return;
      }

      exampleSentences = await getExampleSentences(searchedWord);

    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Failed to load definitions. Please check your internet connection or API keys.";
      });
      print('Search Error: $e');
      return;
    } finally {
      setState(() {
        isLoading = false;
        _isSearching = false;
      });
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) =>
            setState(() {
              _isListening = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            }),
      );

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              if (result.finalResult) {
                _controller.text = _lastWords;
                _isListening = false;
              }
            });
          },
          listenFor: Duration(seconds: 10),
          pauseFor: Duration(seconds: 5),
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  Future<void> addToFavourites(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favourites = prefs.getStringList('favourites') ?? [];

    word = word.trim();
    if (word.isEmpty) return;
    favourites.remove(word);
    favourites.insert(0, word);
    if (favourites.length > 100) {
      favourites = favourites.sublist(0, 100);
    }
    await prefs.setStringList('favourites', favourites);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('favourites').doc(
          uid);
      final doc = await docRef.get();

      List<String> firestoreWords = [];
      if (doc.exists && doc.data()!.containsKey('words')) {
        firestoreWords = List<String>.from(doc['words']);
      }

      firestoreWords.remove(word);
      firestoreWords.insert(0, word);
      if (firestoreWords.length > 100) {
        firestoreWords = firestoreWords.sublist(0, 100);
      }

      await docRef.set({'words': firestoreWords});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$word added to favourites!",
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF3A1F7A),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speakWord(String word) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(word);
  }

  List<String> definitions = [];
  List<String> exampleSentences = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String? error;
  String searchedWord = '';
  bool usedWordnikAsFallback = false;

  Future<List<String>> getMerriamWebsterDefinitions(String word) async {
    final url = "https://dictionaryapi.com/api/v3/references/learners/json/$word?key=$merriamWebsterApiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .where((item) => item is Map && item['shortdef'] != null)
          .expand((item) =>
          (item['shortdef'] as List)
              .where((def) => !def.toString().contains(RegExp(r'<[^>]+>'))))
          .cast<String>()
          .toList();
    } else {
      throw Exception("Failed to load from Merriam-Webster");
    }
  }

  Future<List<String>> getWordnikDefinitions(String word) async {
    try {
      final url = "https://api.wordnik.com/v4/word.json/$word/definitions?limit=5&api_key=$wordnikApiKey";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .where((item) => item is Map && item['text'] != null)
            .where((json) =>
        !json['text'].toString().contains(RegExp(r'<[^>]+>|\$|%')))
            .map((json) => json['text'].toString())
            .toList();
      } else {
        throw Exception("Wordnik API error");
      }
    } catch (e) {
      throw Exception("Failed to load from Wordnik");
    }
  }

  Future<List<String>> getExampleSentences(String word) async {
    try {
      final url = "https://api.wordnik.com/v4/word.json/$word/examples?limit=3&api_key=$wordnikApiKey";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final examples = json['examples'] as List<dynamic>? ?? [];
        return examples
            .where((e) => e is Map && e['text'] != null)
            .map((e) => e['text'].toString())
            .where((text) => !text.contains(RegExp(r'<[^>]+>|\$|%')))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_rounded,
                                  size: width * 0.07,
                                  color: const Color(0xFF4ECDC4)),
                            ),
                            SizedBox(width: width * 0.08),
                            Expanded(
                              child: Text(
                                "Search for a word",
                                style: GoogleFonts.interTight(
                                  fontSize: width * 0.07,
                                  color: theme.textTheme.bodyMedium!.color,
                                  // THEME CHANGE
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.03),
                        Container(
                          height: height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: const Color(0x40FFD700),
                                offset: const Offset(0.0, 2),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1A7B88),
                                    Color(0xFF3A1F7A)
                                  ],
                                  begin: AlignmentDirectional(1, 1),
                                  end: AlignmentDirectional(-1, -1),
                                ),
                              ),
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: height * 0.02),
                                  prefixIcon: Icon(Icons.menu_book_rounded,
                                      color: const Color(0xFF4ECDC4),
                                      size: width * 0.07),
                                  suffixIcon: GestureDetector(
                                    onTap: _listen,
                                    child: Icon(
                                      _isListening ? Icons.mic_off : Icons
                                          .mic_rounded,
                                      color: _isListening
                                          ? Colors.red
                                          : const Color(0xFF4ECDC4),
                                      size: width * 0.07,
                                    ),
                                  ),
                                  hintText: "Type a word...",
                                  hintStyle: GoogleFonts.interTight(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: width * 0.045,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.028),
                        Center(
                          child: SizedBox(
                            height: height * 0.06,
                            width: width * 0.5,
                            child: ElevatedButton(
                              onPressed: _isSearching ? null : () async {
                                _performSearch();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A1F7A),
                                elevation: 6,
                                side: const BorderSide(
                                  color: Color(0xFF1A7B88),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "🔍 Search Now",
                                style: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFD700),
                                  fontSize: width * 0.045,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.028),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x331A7B88),
                                Color(0x333A1F7A)
                              ],
                              begin: AlignmentDirectional(1, 1),
                              end: AlignmentDirectional(-1, -1),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(width * 0.04),
                          child: isLoading
                              ? Center(
                            child: CircularProgressIndicator(
                              color: theme.progressIndicatorTheme
                                  .color,
                            ),
                          )
                              : error != null
                              ? Center(
                            child: Text(
                              error!,
                              style: GoogleFonts.interTight(
                                color: Colors.red,
                                fontSize: width * 0.04,
                              ),
                            ),
                          )
                              : definitions.isEmpty
                              ? Center(
                            child: Text(
                              "No definitions found in any dictionary",
                              style: GoogleFonts.interTight(
                                color: theme.textTheme.bodyMedium!.color,
                                fontSize: width * 0.04,
                              ),
                            ),
                          )
                              : buildDefinitionCard(width, height, theme),
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
    );
  }

  Widget buildDefinitionCard(double width, double height, ThemeData theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(2.0, 10.0, 2.0, 15.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    searchedWord,
                    style: GoogleFonts.interTight(
                      fontSize: width * 0.1,
                      color: theme.textTheme.bodyLarge!.color,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                Container(
                  height: width * 0.14,
                  width: width * 0.14,
                  decoration: BoxDecoration(
                    color: const Color(0x331A7B88),
                    border: Border.all(
                        color: const Color(0xFF4ECDC4), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      speakWord(searchedWord);
                    },
                    child: Icon(Icons.volume_up_rounded,
                        color: const Color(0xFF4ECDC4), size: width * 0.08),
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.02),
            Divider(thickness: 1, color: const Color(0x404ECDC4)),
            SizedBox(height: height * 0.02),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Definitions:",
                  style: GoogleFonts.inter(
                    fontSize: width * 0.045,
                    color: const Color(0xFF4ECDC4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                for (int i = 0; i < definitions.length && i < 2; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: height * 0.015),
                    child: Text(
                      "${i + 1}. ${definitions[i]}",
                      style: GoogleFonts.inter(
                        fontSize: width * 0.045,
                        color: theme.textTheme.bodyMedium!
                            .color, // THEME CHANGE
                      ),
                    ),
                  ),
              ],
            ),

            if (exampleSentences.isNotEmpty) ...[
              SizedBox(height: height * 0.03),
              Text(
                "Examples:",
                style: GoogleFonts.inter(
                  fontSize: width * 0.045,
                  color: const Color(0xFF4ECDC4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.01),
              for (int i = 0; i < exampleSentences.length && i < 2; i++)
                Container(
                  margin: EdgeInsets.only(bottom: height * 0.02),
                  padding: EdgeInsets.all(width * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0x331A7B88),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${i + 1}. ${exampleSentences[i]}",
                    style: GoogleFonts.inter(
                      fontSize: width * 0.042,
                      color: theme.textTheme.bodyMedium!.color, // THEME CHANGE
                    ),
                  ),
                ),
            ],

            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await addToFavourites(searchedWord);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0x331A7B88),
                      side: BorderSide(color: Color(0xFF4ECDC4)),
                    ),
                    child: Text(
                      "🤍 Add to favourites",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (searchedWord.isNotEmpty && definitions.isNotEmpty) { // Only navigate if a word is successfully searched
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SynonymsPage(word: searchedWord),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please search for a word first!", style: GoogleFonts.inter(color: Colors.white)),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0x331A7B88),
                      side: BorderSide(color: Color(0xFF4ECDC4)),
                    ),
                    child: Text(
                      "🔁 Synonyms",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}