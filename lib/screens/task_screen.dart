import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/main.dart';
import '../models/task_model.dart';
import '../providers/theme_provider.dart';
import '../services/task_service.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('User Options', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _logout();
              }
            )
          ]
        )
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: user != null ? _taskService.getTasks(user.uid) : Stream.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tasks = snapshot.data ?? [];
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _taskService.deleteTask(task.id);
                  },
                ),
                onTap: () {
                  _showUpdateTaskDialog(task);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              child: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _showAddTaskDialog();
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddTaskDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDueDate = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description')
                  ),
                  SizedBox(height: 16),
                  Text('Due Date: ${_selectedDueDate != null ? _formatDateTime(_selectedDueDate!) : 'Not selected'}'),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedDueDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Text('Select Due Date and Time'),
                  ),
                ],
              );
            }
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_selectedDueDate != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  final newTask = TaskModel(
                    id: '',
                    title: _titleController.text,
                    description: _descriptionController.text,
                    userID: user!.uid,
                    dueDate: _selectedDueDate!,
                  );
                  _taskService.addTask(newTask);
                  Navigator.of(context).pop();

                  await _taskService.scheduleNotification(_selectedDueDate!, newTask.title, user.uid);
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a due date')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateTaskDialog(TaskModel task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedDueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Task'),
          content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description')
                    ),
                    SizedBox(height: 16),
                    Text('Due Date: ${_selectedDueDate != null ? _formatDateTime(_selectedDueDate!) : 'Not selected'}'),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _selectedDueDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Text('Select Due Date and Time'),
                    ),
                  ],
                );
              }
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_selectedDueDate != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  final updatedTask = TaskModel(
                    id: task.id,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: _selectedDueDate!,
                    userID: user!.uid,
                    isCompleted: task.isCompleted,
                  );
                  _taskService.updateTask(updatedTask);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a due date.')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController _oldPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPasswordController,
                decoration: InputDecoration(labelText: 'Old Password'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  try {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: _oldPasswordController.text,
                    );

                    await user.reauthenticateWithCredential(credential);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password changed successfully!')));
                  }
                  catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password: ${e.toString()}')));
                  }
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userID');
    await flutterLocalNotificationsPlugin.cancelAll();
    Navigator.of(context).pushReplacementNamed('/');
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}