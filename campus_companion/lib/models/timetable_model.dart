class TimetableModel {
  final String id;
  final String subject;
  final String time;

  TimetableModel({required this.id, required this.subject, required this.time});

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      id: json['id'],
      subject: json['subject'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'subject': subject, 'time': time};
  }
}
