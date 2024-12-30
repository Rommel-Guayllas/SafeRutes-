import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart'; // Archivo generado por FlutterFire CLI
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'Flutter Firebase Auth CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authService.isLoading
          ? Scaffold(body: Center(child: CircularProgressIndicator()))
          : authService.user == null
              ? LoginPage()
              : HomePage(),
    );
  }
}
