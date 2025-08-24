import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:dictionary_app/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dictionary_app/search_history.dart';
import 'package:dictionary_app/searchpage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> historyWords = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    await SearchHistory.load();
    List<String> mergedWords = [];
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('history').doc(uid);

      // Fetch from Firestore
      final doc = await docRef.get();
      List<String> firestoreWords = [];
      if (doc.exists && doc.data()!.containsKey('words')) {
        firestoreWords = List<String>.from(doc['words']);
      }

      Set<String> tempSet = Set<String>();
      for (String word in firestoreWords) {
        tempSet.add(word);
      }
      for (String word in SearchHistory.words) {
        tempSet.add(word);
      }
      List<String> combinedList = List.from(SearchHistory.words);
      for (String word in firestoreWords) {
        if (!combinedList.contains(word)) {
          combinedList.insert(0, word); // Insert at the beginning to maintain latest-first
        }
      }
      mergedWords = combinedList.take(100).toList(); // Ensure max size
      SearchHistory.words = mergedWords;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', mergedWords);
      await docRef.set({'words': mergedWords});

    } else {
      mergedWords = SearchHistory.words;
    }

    setState(() {
      historyWords = mergedWords;
    });
  }

  void _navigateToSearchPage(String word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordSearchPage(initialWord: word),
      ),
    );
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
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        title: Text(
          "Your History",
          style: TextStyle(
            fontSize: width * 0.06,
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: historyWords.isEmpty
          ? Center(
        child: Text(
          "No history found",
          style: TextStyle(
            fontSize: width * 0.045,
            color: theme.textTheme.bodyMedium?.color ?? Colors.white,
          ),
        ),
      )
          : ListView.separated(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.02,
          horizontal: width * 0.04,
        ),
        itemCount: historyWords.length,
        separatorBuilder: (_, __) => Divider(
          color: theme.dividerColor,
        ),
        itemBuilder: (context, index) {
          final word = historyWords[index];
          return ListTile(
            title: Text(
              word,
              style: TextStyle(
                fontSize: width * 0.045,
                color: theme.textTheme.bodyMedium?.color ?? Colors.white,
              ),
            ),
            leading: Icon(Icons.history, color: theme.primaryColor),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                  Colors.white70,
            ),
            onTap: () {
              _navigateToSearchPage(word);
            },
          );
        },
      ),
    );
  }
}