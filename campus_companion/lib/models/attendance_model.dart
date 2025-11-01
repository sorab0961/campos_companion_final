class AttendanceModel {
  final String id;
  final String userId;
  final DateTime date;
  final bool present;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.present,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      present: json['present'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'present': present,
    };
  }
}
