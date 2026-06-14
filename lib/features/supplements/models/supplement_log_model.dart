class SupplementLog {
  const SupplementLog({
    required this.date,
    required this.takenSupplementIds,
  });

  final DateTime date;
  final List<String> takenSupplementIds;

  SupplementLog copyWith({
    DateTime? date,
    List<String>? takenSupplementIds,
  }) {
    return SupplementLog(
      date: date ?? this.date,
      takenSupplementIds: takenSupplementIds ?? this.takenSupplementIds,
    );
  }

  bool isTaken(String supplementId) => takenSupplementIds.contains(supplementId);

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'takenSupplementIds': takenSupplementIds,
    };
  }

  factory SupplementLog.fromJson(Map<String, dynamic> json) {
    return SupplementLog(
      date: DateTime.parse(json['date'] as String),
      takenSupplementIds:
          (json['takenSupplementIds'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
    );
  }
}
