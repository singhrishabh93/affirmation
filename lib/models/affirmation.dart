class Affirmation {
  final String id;
  final String text;
  final bool isFavorite;
  final DateTime createdAt;
  final String? category;

  Affirmation({
    required this.id,
    required this.text,
    this.isFavorite = false,
    required this.createdAt,
    this.category,
  });

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'],
      text: json['text'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  Affirmation copyWith({
    String? id,
    String? text,
    bool? isFavorite,
    DateTime? createdAt,
    String? category,
  }) {
    return Affirmation(
      id: id ?? this.id,
      text: text ?? this.text,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}