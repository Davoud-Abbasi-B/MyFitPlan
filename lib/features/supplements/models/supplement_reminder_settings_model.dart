class SupplementReminderSettings {
  const SupplementReminderSettings({
    required this.vitaminDEnabled,
    this.activatedAt,
    this.totalWeeks = 8,
  });

  final bool vitaminDEnabled;
  final DateTime? activatedAt;
  final int totalWeeks;

  SupplementReminderSettings copyWith({
    bool? vitaminDEnabled,
    DateTime? activatedAt,
    bool clearActivatedAt = false,
    int? totalWeeks,
  }) {
    return SupplementReminderSettings(
      vitaminDEnabled: vitaminDEnabled ?? this.vitaminDEnabled,
      activatedAt: clearActivatedAt ? null : (activatedAt ?? this.activatedAt),
      totalWeeks: totalWeeks ?? this.totalWeeks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitaminDEnabled': vitaminDEnabled,
      'activatedAt': activatedAt?.toIso8601String(),
      'totalWeeks': totalWeeks,
    };
  }

  factory SupplementReminderSettings.fromJson(Map<String, dynamic> json) {
    return SupplementReminderSettings(
      vitaminDEnabled: json['vitaminDEnabled'] as bool? ?? false,
      activatedAt: (json['activatedAt'] as String?) == null
          ? null
          : DateTime.parse(json['activatedAt'] as String),
      totalWeeks: json['totalWeeks'] as int? ?? 8,
    );
  }
}
