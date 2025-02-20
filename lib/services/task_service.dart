import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';


// CRUD operations
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create
  Future<void> addTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  // Read
  Stream<List<TaskModel>> getTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>)
          ..id = doc.id;
      }).toList();
    });
  }

  // Update
  Future<void> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  // Delete
  Future<void> deleteTask(String id) async {
    await _firestore.collection('tasks').doc(id).delete();
  }
}