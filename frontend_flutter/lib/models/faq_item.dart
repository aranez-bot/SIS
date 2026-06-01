class FaqItem {
  FaqItem({
    this.id,
    required this.question,
    required this.answer,
    this.category,
    this.isActive = true,
  });

  final int? id;
  final String question;
  final String answer;
  final String? category;
  final bool isActive;

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'],
        question: json['question'] ?? '',
        answer: json['answer'] ?? '',
        category: json['category'],
        isActive: json['is_active'] ?? true,
      );
}
