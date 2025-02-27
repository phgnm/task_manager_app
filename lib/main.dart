import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/screens/task_screen.dart';
import 'package:task_manager_app/services/notif_service.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init notif
  await NotiService().initNotification();

  // Init firebase
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userID = prefs.getString('userID');

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MyApp(userID: userID),
  ));
}

class MyApp extends StatelessWidget {
  final String? userID;

  const MyApp({super.key, this.userID});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: "Task Manager",
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => userID != null ? TaskScreen() : LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}

