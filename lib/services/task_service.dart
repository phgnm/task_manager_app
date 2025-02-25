import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task_model.dart';

class TimeZone {
  factory TimeZone() => _this;

  TimeZone._() {
    initializeTimeZones();
  }

  static TimeZone _this = TimeZone();

  Future<String> getTimeZoneName() async => FlutterTimezone.getLocalTimezone();
  Future<tz.Location> getLocation([String? timeZoneName]) async {
    if(timeZoneName == null || timeZoneName.isEmpty) {
      timeZoneName = await getTimeZoneName();
    }
    return tz.getLocation(timeZoneName);
  }
}

final timeZone = TimeZone();

String timeZoneName = timeZone.getTimeZoneName() as String;

final location = timeZone.getLocation(timeZoneName);


// CRUD operations + notifications
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create
  Future<String> addTask(TaskModel task) async {
    DocumentReference docRef = await _firestore.collection('tasks').add(task.toMap());
    return docRef.id;
  }

  // Read
  Stream<List<TaskModel>> getTasks(String userID) {
    return _firestore
        .collection('tasks')
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data())
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