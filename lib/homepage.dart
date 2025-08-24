import 'package:dictionary_app/drawer.dart';
import 'package:dictionary_app/favouritespage.dart';
import 'package:dictionary_app/historypage.dart';
import 'package:dictionary_app/randomwordpage.dart';
import 'package:dictionary_app/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dictionary_app/loginpage.dart';
import 'package:dictionary_app/wotd.dart';
import 'package:dictionary_app/word_challengepage.dart';
import 'package:provider/provider.dart';
import 'package:dictionary_app/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldkey = GlobalKey<ScaffoldState>();
  String word = '';
  String definition = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWordOfTheDay();
  }

  void loadWordOfTheDay() async {
    final result = await WordOfTheDayService().getWordOfTheDay();
    setState(() {
      word = result['word'] ?? '';
      definition = result['definition'] ?? '';
      isLoading = false;
    });
  }

  logout() async {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      key: scaffoldkey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: OpenDrawer(),
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            scaffoldkey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(7.0, 0.0, 0.0, 0.0),
            child: Container(
              width: width * 0.12,
              height: width * 0.12,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                  stops: [0, 1],
                  begin: AlignmentDirectional(1, 1),
                  end: AlignmentDirectional(-1, -1),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book,
                size: 30,
                color: Colors.white
              ),
            ),
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          "WordQuest",
          style: TextStyle(
            fontFamily: "InterTight",
            fontSize: width * 0.07,
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              width: width * 0.12,
              height: width * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeProvider.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 30,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(13.0, 17.0, 13.0, 9.0),
              child: Container(
                height: height * 0.20,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(1, 1),
                    end: AlignmentDirectional(-1, -1),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(15.0, 15.0, 15.0, 15.0),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Word of the day",
                            style: TextStyle(
                                fontFamily: "InterTight",
                                fontSize: width * 0.06,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const Icon(
                            Icons.auto_awesome,
                            size: 30,
                            color: Colors.white,
                          )
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: isLoading
                            ? Center(
                          child: CircularProgressIndicator(
                            color: theme.progressIndicatorTheme.color,
                          ),
                        )
                            : Text(
                          word,
                          style: TextStyle(
                            fontFamily: "InterTight",
                            fontWeight: FontWeight.w800,
                            fontSize: width * 0.11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        definition.isEmpty ? '' : definition,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.05,
                          height: 1.1,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WordSearchPage()));
              },
              child: Padding(
                padding:
                const EdgeInsetsDirectional.fromSTEB(15.0, 3.0, 15.0, 12.0),
                child: Container(
                  width: double.infinity,
                  height: height * 0.20,
                  decoration: BoxDecoration(
                      color: const Color(0xFF1A7B88),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: width * 0.15,
                        height: width * 0.15,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.search,
                          size: 40,
                          color: Color(0xFF1A7B88),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Search for a word",
                          style: TextStyle(
                              fontSize: width * 0.06,
                              color: Colors.white,
                              fontFamily: "InterTight",
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FavouritesPage()));
                  },
                  child: Container(
                    margin:
                    const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
                    height: height * 0.20,
                    width: width * 0.43,
                    decoration: BoxDecoration(
                        color: const Color(0xFF3A1F7A),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: width * 0.14,
                          width: width * 0.14,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(
                            Icons.favorite,
                            size: 38,
                            color: Color(0xFF3A1F7A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your\n Favourites",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.055,
                            fontFamily: "InterTight",
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HistoryPage()));
                  },
                  child: Container(
                    margin:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
                    height: height * 0.20,
                    width: width * 0.43,
                    decoration: BoxDecoration(
                        color: const Color(0xFF2D4A8A),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: width * 0.14,
                          width: width * 0.14,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(
                            Icons.history,
                            size: 38,
                            color: Color(0xFF3A1F7A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your\n History",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.055,
                            fontFamily: "InterTight",
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding:
              const EdgeInsetsDirectional.fromSTEB(15.0, 10.0, 15.0, 10.0),
              child: Container(
                height: height * 0.13,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                        stops: [0, 1],
                        begin: AlignmentDirectional(1, 1),
                        end: AlignmentDirectional(-1, -1)),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Word Challenge",
                            style: TextStyle(
                                fontFamily: "InterTight",
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: width * 0.06)),
                        Text("Test your vocabulary skills",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.045,
                            ))
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WordChallengePage()));
                      },
                      child: Container(
                        height: width * 0.14,
                        width: width * 0.14,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Color(0xFF1A7B88),
                          size: 35,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RandomWordDice()));
              },
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                height: width * 0.16,
                width: width * 0.16,
                decoration: const BoxDecoration(
                    color: Color(0xFF1A7B88), shape: BoxShape.circle),
                child: const Icon(
                  Icons.casino,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}