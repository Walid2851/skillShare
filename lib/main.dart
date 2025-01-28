import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skill/screens/chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'firebase_options.dart';
import '../controller/auth_controller.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://dcbuqpvjxdonywobsrtg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjYnVxcHZqeGRvbnl3b2JzcnRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxNjk1MzEsImV4cCI6MjA1MTc0NTUzMX0.tRgqTzSndCAoWJgGLJESoNMdr3Dbh1lJwbM7KTK6fRY',
  );

  Get.put(AuthController());
  runApp(MyApp()); // Removed the home parameter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      title: 'Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      initialRoute: '/login', // This will be your starting route
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/chat', page: () => ChatScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    );
  }
}