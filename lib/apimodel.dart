
class DicrionaryDart {
  String? id;
  String? partOfSpeech;
  String attributionText;
  String sourceDictionary;
  String text;
  String? sequence;
  int? score;
  String word;
  String attributionUrl;
  String wordnikUrl;
  List<dynamic> citations;
  List<dynamic> exampleUses;
  List<dynamic> labels;
  List<dynamic> notes;
  List<dynamic> relatedWords;
  List<dynamic> textProns;

  DicrionaryDart({
    this.id,
    this.partOfSpeech,
    required this.attributionText,
    required this.sourceDictionary,
    required this.text,
    this.sequence,
    this.score,
    required this.word,
    required this.attributionUrl,
    required this.wordnikUrl,
    required this.citations,
    required this.exampleUses,
    required this.labels,
    required this.notes,
    required this.relatedWords,
    required this.textProns,
  });

  factory DicrionaryDart.fromJson(Map<String, dynamic> json) {
    return DicrionaryDart(
      id: json['id']?.toString(),
      partOfSpeech: json['partOfSpeech'],
      attributionText: json['attributionText'] ?? '',
      sourceDictionary: json['sourceDictionary'] ?? '',
      text: json['text'] ?? '',
      sequence: json['sequence'],
      score: json['score'],
      word: json['word'] ?? '',
      attributionUrl: json['attributionUrl'] ?? '',
      wordnikUrl: json['wordnikUrl'] ?? '',
      citations: json['citations'] ?? [],
      exampleUses: json['exampleUses'] ?? [],
      labels: json['labels'] ?? [],
      notes: json['notes'] ?? [],
      relatedWords: json['relatedWords'] ?? [],
      textProns: json['textProns'] ?? [],
    );
  }


}
