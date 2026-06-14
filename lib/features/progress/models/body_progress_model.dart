class BodyProgress {
  const BodyProgress({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.waistCm,
    this.steps,
    this.note,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double waistCm;
  final int? steps;
  final String? note;

  BodyProgress copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    double? waistCm,
    int? steps,
    bool clearSteps = false,
    String? note,
    bool clearNote = false,
  }) {
    return BodyProgress(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      steps: clearSteps ? null : (steps ?? this.steps),
      note: clearNote ? null : (note ?? this.note),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'steps': steps,
      'note': note,
    };
  }

  factory BodyProgress.fromJson(Map<String, dynamic> json) {
    return BodyProgress(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      waistCm: (json['waistCm'] as num).toDouble(),
      steps: json['steps'] as int?,
      note: json['note'] as String?,
    );
  }
}
