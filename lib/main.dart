import 'package:edutrack_application/firebase_options.dart';
import 'package:edutrack_application/modules/Admin/presentation/views/admin_register.dart';

import 'package:edutrack_application/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduTrack',
      theme: ThemeData(
        // Corrected syntax: generate color scheme from a seed
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // optional: for Material3 styling
      ),
      // You can change currentUserRole to 'admin', 'trainer', etc.
     home: SplashScreen(),
    
    );
  }
}
