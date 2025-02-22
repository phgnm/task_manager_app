import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager_app/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task_model.dart';

class TimeZone {
  factory TimeZone() => _this ?? TimeZone._();

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
  Future<void> addTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
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

  Future<void> scheduleNotification(DateTime dueDate, String title, String userID) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_reminder',
      'Task Scheduler',
      channelDescription: 'Your "$title" task is about to due, please check on it!',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Reminder',
      title,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}