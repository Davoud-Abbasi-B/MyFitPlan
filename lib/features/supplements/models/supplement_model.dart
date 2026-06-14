class Supplement {
  const Supplement({
    required this.id,
    required this.name,
    required this.scheduleLabel,
    this.note,
  });

  final String id;
  final String name;
  final String scheduleLabel;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduleLabel': scheduleLabel,
      'note': note,
    };
  }

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['id'] as String,
      name: json['name'] as String,
      scheduleLabel: json['scheduleLabel'] as String,
      note: json['note'] as String?,
    );
  }
}
