class TodoUser {
  final String id;
  final String name;

  TodoUser({required this.id, required this.name});

  factory TodoUser.fromJson(Map<String, dynamic> json) {
    return TodoUser(id: json['id'], name: json['name']);
  }
}

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final TodoUser createdBy;
  final DateTime? completedAt;
  final TodoUser? completedBy;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.createdBy,
    this.completedAt,
    this.completedBy,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: TodoUser.fromJson(json['created_by'] as Map<String, dynamic>),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      completedBy: json['completed_by'] != null
          ? TodoUser.fromJson(json['completed_by'] as Map<String, dynamic>)
          : null,
    );
  }
}
