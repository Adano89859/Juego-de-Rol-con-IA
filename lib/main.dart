import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/character_creation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC8cCoSjRFpORkxKGz3tp-hy9AAWcmpQ",
      authDomain: "quest-master-8d028.firebaseapp.com",
      projectId: "quest-master-8d028",
      databaseURL: "https://quest-master-8d028-default-rtdb.firebaseio.com",
      storageBucket: "quest-master-8d028.firebasestorage.app",
      messagingSenderId: "1087677555780",
      appId: "1:1087677555780:web:ae3ca06b566a7b521c4811",
    ),
  );
  
  runApp(const QuestMasterApp());
}

class QuestMasterApp extends StatelessWidget {
  const QuestMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quest Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1a1a2e),
        scaffoldBackgroundColor: const Color(0xFF16213e),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0f3460),
          secondary: Color(0xFFe94560),
          surface: Color(0xFF1a1a2e),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1a1a2e).withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      home: const CharacterCreationScreen(),
    );
  }
}