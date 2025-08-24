import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchHistory {
  static List<String> words = [];

  static Future<void> add(String word) async {
    word = word.trim();
    if (word.isEmpty) return;
    await load();

    words.remove(word);
    words.insert(0, word);

    if (words.length > 100) {
      words = words.sublist(0, 100);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', words);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('history').doc(user.uid);
      await docRef.set({'words': words});
    }
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    words = prefs.getStringList('search_history') ?? [];
  }
}
