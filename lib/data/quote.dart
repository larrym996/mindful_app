class Quote {
  final String text;
  final String author;
  int? id;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? 'No quote available',
      author: json['a'] ?? 'Unknown');
  }

  Map<String, dynamic> toMap() {
    return {
      'q': text,
      'a': author,
    };
  }
}