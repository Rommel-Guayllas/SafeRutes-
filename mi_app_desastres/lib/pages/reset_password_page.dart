import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.resetPassword(emailCtrl.text);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Revisa tu correo')));
                Navigator.pop(context);
              },
              child: Text('Recuperar'),
            ),
          ],
        ),
      ),
    );
  }
}
