class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  final DateTime createdAt;
  DateTime date;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'date': date.toIso8601String(),
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'],
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'],
    date: DateTime.parse(json['date']),
  );
}
