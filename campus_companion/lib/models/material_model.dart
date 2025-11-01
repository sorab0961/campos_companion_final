class MaterialModel {
  final String id;
  final String title;
  final String? description;
  final String? subject;
  final String? link;
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.title,
    this.description,
    this.subject,
    this.link,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'],
      link: json['link'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'link': link,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
