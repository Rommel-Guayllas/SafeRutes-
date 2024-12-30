import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final error = await authService.signUp(
                    emailCtrl.text, passCtrl.text, nameCtrl.text);
                if (error != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
