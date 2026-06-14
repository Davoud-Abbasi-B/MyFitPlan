class CravingLog {
  const CravingLog({
    required this.id,
    required this.date,
    required this.trigger,
    required this.healthyAlternative,
    required this.result,
  });

  final String id;
  final DateTime date;
  final String trigger;
  final String healthyAlternative;
  final String result;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'trigger': trigger,
      'healthyAlternative': healthyAlternative,
      'result': result,
    };
  }

  factory CravingLog.fromJson(Map<String, dynamic> json) {
    return CravingLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      trigger: json['trigger'] as String,
      healthyAlternative: json['healthyAlternative'] as String,
      result: json['result'] as String,
    );
  }
}
