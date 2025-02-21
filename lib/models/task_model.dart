class TaskModel {
  String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String userID;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.userID,
    this.isCompleted = false,
  });

  // Convert for Firestore retrieving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'userID': userID,
      'isCompleted': isCompleted,
    };
  }

  // Create TaskModel from Map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      userID: map['userID'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}