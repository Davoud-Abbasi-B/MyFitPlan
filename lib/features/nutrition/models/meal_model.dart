class Meal {
  const Meal({
    required this.id,
    required this.title,
    required this.description,
    required this.proteinGrams,
    this.isPriority = false,
  });

  final String id;
  final String title;
  final String description;
  final int proteinGrams;
  final bool isPriority;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'proteinGrams': proteinGrams,
      'isPriority': isPriority,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      proteinGrams: json['proteinGrams'] as int,
      isPriority: json['isPriority'] as bool? ?? false,
    );
  }
}
