import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dictionary_app/theme_provider.dart';

class SynonymsPage extends StatefulWidget {
  final String word;

  const SynonymsPage({super.key, required this.word});

  @override
  State<SynonymsPage> createState() => _SynonymsPageState();
}

class _SynonymsPageState extends State<SynonymsPage> {
  late String merriamWebsterThesaurusApiKey;

  List<String> synonyms = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    merriamWebsterThesaurusApiKey = dotenv.env['MERRIAM_THESAURUS']!;
    _fetchSynonyms();
  }

  Future<void> _fetchSynonyms() async {
    setState(() {
      isLoading = true;
      error = null;
      synonyms = [];
    });

    try {
      final url = "https://www.dictionaryapi.com/api/v3/references/thesaurus/json/${widget.word}?key=$merriamWebsterThesaurusApiKey";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        List<String> collectedSynonyms = [];

        for (var entry in jsonList) {
          if (entry is Map<String, dynamic> && entry['meta'] != null) {
            final meta = entry['meta'] as Map<String, dynamic>;
            if (meta['syns'] != null) {
              for (var synGroup in meta['syns']) {
                if (synGroup is List) {
                  collectedSynonyms.addAll(List<String>.from(synGroup.map((s) => s.toString())));
                }
              }
            }
          }
        }
        synonyms = collectedSynonyms.toSet().toList()..sort();

        if (synonyms.isEmpty) {
          error = "No synonyms found for '${widget.word}'";
        }
      } else if (response.statusCode == 404) {
        error = "Word not found or no synonyms for '${widget.word}'";
      } else {
        error = "Failed to load synonyms (Status: ${response.statusCode})";
      }
    } catch (e) {
      error = "Failed to load synonyms. Please check your internet connection.";
      print('Merriam-Webster Thesaurus API Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                                "Synonyms for:",
                                style: GoogleFonts.interTight(
                                  fontSize: width * 0.07,
                                  color: theme.textTheme.bodyMedium!.color,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.16),
                          child: Text(
                            widget.word,
                            style: GoogleFonts.interTight(
                              fontSize: width * 0.08,
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: height * 0.03),
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
                              color: theme.progressIndicatorTheme.color,
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
                              : synonyms.isEmpty
                              ? Center(
                            child: Text(
                              "No synonyms found.",
                              style: GoogleFonts.interTight(
                                color: theme.textTheme.bodyMedium!.color,
                                fontSize: width * 0.04,
                              ),
                            ),
                          )
                              : _buildSynonymsList(width, height, theme),
                        ),
                        SizedBox(height: height * 0.02),
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

  Widget _buildSynonymsList(double width, double height, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Synonyms:",
          style: GoogleFonts.inter(
            fontSize: width * 0.045,
            color: const Color(0xFF4ECDC4),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: height * 0.01),
        Wrap(
          spacing: width * 0.02,
          runSpacing: height * 0.01,
          children: synonyms.map((synonym) {
            return Chip(
              label: Text(
                synonym,
                style: GoogleFonts.interTight(
                  fontSize: width * 0.04,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFF3A1F7A),
              side: const BorderSide(color: Color(0xFF1A7B88), width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
            );
          }).toList(),
        ),
      ],
    );
  }
}