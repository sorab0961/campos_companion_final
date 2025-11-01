class NoticeModel {
  final String id;
  final String title;
  final String content;

  NoticeModel({required this.id, required this.title, required this.content});

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content};
  }
}
