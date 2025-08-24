import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:dictionary_app/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dictionary_app/searchpage.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<String> favouriteWords = [];

  @override
  void initState() {
    super.initState();
    _initFirebaseAndLoadFavourites();
  }

  Future<void> _initFirebaseAndLoadFavourites() async {
    await _ensureUserLoggedIn();
    await loadFavourites();
  }

  Future<void> _ensureUserLoggedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  Future<void> loadFavourites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('favourites').doc(user.uid).get();
    final words = (doc.data()?['words'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [];

    setState(() {
      favouriteWords = words;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', words);
  }

  Future<void> removeFavourite(String word) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      favouriteWords.remove(word);
    });

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('favourites')
        .doc(user.uid)
        .set({'words': favouriteWords});

    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', favouriteWords);
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
        centerTitle: true,
        title: Text(
          'Your Favourites',
          style: GoogleFonts.interTight(
            fontSize: width * 0.06,
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favouriteWords.isEmpty
          ? Center(
        child: Text(
          'No favourites yet!',
          style: GoogleFonts.interTight(
            fontSize: width * 0.05,
            color: theme.textTheme.bodyMedium?.color ?? Colors.white,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(width * 0.04),
        itemCount: favouriteWords.length,
        itemBuilder: (context, index) {
          final word = favouriteWords[index];
          return InkWell(
            onTap: () => _navigateToSearchPage(word),
            child: Container(
              margin: EdgeInsets.only(bottom: height * 0.02),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    word,
                    style: GoogleFonts.interTight(
                      fontSize: width * 0.06,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => removeFavourite(word),
                    icon: const Icon(
                      Icons.favorite,
                      color: Color(0xFFFFD700),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
