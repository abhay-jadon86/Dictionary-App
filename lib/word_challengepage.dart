import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dictionary_app/theme_provider.dart';

class WordChallengePage extends StatefulWidget {
  const WordChallengePage({super.key});

  @override
  State<WordChallengePage> createState() => _WordChallengePageState();
}

class _WordChallengePageState extends State<WordChallengePage> {
  late String apiKey ;
  final int totalQuestions = 5;
  final int apiTimeoutSeconds = 8;

  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int selectedIndex = -1;
  int score = 0;
  bool answered = false;
  bool showNext = false;
  bool isLoading = true;
  bool showResult = false;
  String? errorMessage;

  final Map<String, String> _fallbackWords = {
    'ephemeral': 'Lasting for a very short time',
    'ubiquitous': 'Present everywhere simultaneously',
    'serendipity': 'The occurrence of events by chance in a happy way',
    'eloquent': 'Fluent or persuasive in speaking or writing',
    'resilient': 'Able to withstand or recover quickly from difficult conditions',
    'ambiguous': 'Open to more than one interpretation',
    'voracious': 'Wanting or devouring great quantities of food',
    'meticulous': 'Showing great attention to detail',
    'quintessential': 'Representing the most perfect or typical example',
    'altruistic': 'Showing selfless concern for others'
  };

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['WORDNIK_KEY']!;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiQuestions = await _fetchApiQuestions();

      if (apiQuestions.length >= totalQuestions) {
        setState(() {
          questions = apiQuestions.take(totalQuestions).toList();
          isLoading = false;
        });
        return;
      }

      final fallbackQuestions = _getFallbackQuestions();
      final combinedQuestions = [...apiQuestions, ...fallbackQuestions]
        ..shuffle();

      setState(() {
        questions = combinedQuestions.take(totalQuestions).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading questions: $e');
      setState(() {
        questions = _getFallbackQuestions()..shuffle();
        questions = questions.take(totalQuestions).toList();
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchApiQuestions() async {
    try {
      final wordsResponse = await http.get(
          Uri.parse('https://api.wordnik.com/v4/words.json/randomWords?limit=${totalQuestions * 2}&api_key=$apiKey')
      ).timeout(Duration(seconds: apiTimeoutSeconds));

      if (wordsResponse.statusCode != 200) return [];

      final List<dynamic> wordList = json.decode(wordsResponse.body);
      final words = wordList
          .map((e) => e['word'] as String)
          .where((word) => word.length > 3)
          .toList();

      final definitionFutures = words.map((word) => _fetchDefinition(word)).toList();
      final definitions = await Future.wait(definitionFutures);

      final validQuestions = <Map<String, dynamic>>[];
      for (int i = 0; i < words.length; i++) {
        if (definitions[i] != null && validQuestions.length < totalQuestions) {
          final question = await _createQuestion(words[i], definitions[i]!);
          validQuestions.add(question);
        }
      }

      return validQuestions;
    } catch (e) {
      debugPrint('Error fetching API questions: $e');
      return [];
    }
  }

  Future<String?> _fetchDefinition(String word) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.wordnik.com/v4/word.json/$word/definitions?limit=1&api_key=$apiKey')
      ).timeout(Duration(seconds: apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final definitions = json.decode(response.body) as List;
        if (definitions.isNotEmpty && definitions[0]['text'] != null) {
          return _cleanDefinition(definitions[0]['text']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching definition for $word: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _createQuestion(String word, String correctDefinition) async {
    final wrongOptions = _fallbackWords.values
        .where((def) => def != correctDefinition)
        .toList()
      ..shuffle();

    final options = [correctDefinition, ...wrongOptions.take(3)]..shuffle();
    return {
      'word': word,
      'options': options,
      'answerIndex': options.indexOf(correctDefinition),
    };
  }

  List<Map<String, dynamic>> _getFallbackQuestions() {
    return _fallbackWords.entries.map((entry) {
      final wrongOptions = _fallbackWords.values
          .where((def) => def != entry.value)
          .toList()
        ..shuffle();

      final options = [entry.value, ...wrongOptions.take(3)]..shuffle();
      return {
        'word': entry.key,
        'options': options,
        'answerIndex': options.indexOf(entry.value),
      };
    }).toList();
  }

  String _cleanDefinition(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .trim();
  }

  void _handleAnswer(int index) {
    if (!answered && !isLoading) {
      setState(() {
        selectedIndex = index;
        answered = true;
        showNext = true;
        if (index == questions[currentQuestionIndex]['answerIndex']) {
          score++;
        }
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedIndex = -1;
        answered = false;
        showNext = false;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      questions = [];
      score = 0;
      currentQuestionIndex = 0;
      selectedIndex = -1;
      answered = false;
      showNext = false;
      showResult = false;
      isLoading = true;
      errorMessage = null;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        title: Text(
          "Word Challenge",
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontFamily: "InterTight",
            fontWeight: FontWeight.bold,
            fontSize: width * 0.06,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildLoadingScreen(width, theme)
          : errorMessage != null || questions.isEmpty
          ? _buildErrorScreen(width, theme)
          : showResult
          ? _buildResultScreen(width, theme)
          : _buildQuizScreen(width, theme),
    );
  }

  Widget _buildLoadingScreen(double width, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 20),
          Text(
            "Loading your word challenge...",
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color ?? Colors.white,
              fontSize: width * 0.045,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "(This should take less than 10 seconds)",
            style: TextStyle(
              color: (theme.textTheme.bodyMedium?.color ?? Colors.white).withOpacity(0.7),
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(double width, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 50),
          const SizedBox(height: 20),
          Text(
            errorMessage ?? "Couldn't load enough questions",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color ?? Colors.white,
              fontSize: width * 0.045,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _restartQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text("Try Again", style: TextStyle(color: theme.primaryTextTheme.labelLarge?.color)),
          )
        ],
      ),
    );
  }

  Widget _buildResultScreen(double width, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "🎉 Quiz Completed!",
            style: TextStyle(
              color: theme.textTheme.headlineMedium?.color ?? Colors.white,
              fontSize: width * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Your Score: $score / ${questions.length}",
            style: TextStyle(
              color: Colors.amber,
              fontSize: width * 0.06,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A7B88),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: _restartQuiz,
            child: Text("Play Again", style: TextStyle(color: theme.primaryTextTheme.labelLarge?.color)),
          )
        ],
      ),
    );
  }

  Widget _buildQuizScreen(double width, ThemeData theme) {
    final currentQuestion = questions[currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Test your vocabulary skills",
            style: TextStyle(
              color: (theme.textTheme.bodyMedium?.color ?? Colors.white).withOpacity(0.7),
              fontSize: width * 0.045,
              fontFamily: "InterTight",
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "What does '${currentQuestion['word']}' mean?",
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: width * 0.055,
              fontFamily: "InterTight",
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),
          ...currentQuestion['options'].asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return GestureDetector(
              onTap: () => _handleAnswer(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: answered
                      ? (index == currentQuestion['answerIndex']
                      ? Colors.green
                      : (index == selectedIndex ? Colors.red : const Color(0xFF1A7B88)))
                      : const Color(0xFF1A7B88),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.045,
                    fontFamily: "InterTight",
                  ),
                ),
              ),
            );
          }).toList(),
          if (answered) ...[
            const SizedBox(height: 15),
            Center(
              child: Text(
                selectedIndex == currentQuestion['answerIndex']
                    ? "✅ Correct!"
                    : "❌ Wrong answer",
                style: TextStyle(
                  color: selectedIndex == currentQuestion['answerIndex']
                      ? Colors.green
                      : Colors.red,
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (showNext) ...[
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7B88),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: _nextQuestion,
                child: Text(
                  currentQuestionIndex < questions.length - 1
                      ? "Next Question"
                      : "Show Result",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}