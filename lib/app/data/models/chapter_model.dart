class Chapter {
  final String id;
  final String title;

  Chapter({required this.id, required this.title});

  // Add this factory constructor
  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
    );
  }
}
