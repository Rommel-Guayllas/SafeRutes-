import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameCtrl = TextEditingController();

  String? displayName;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authService.user!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        displayName = doc.data()!['displayName'];
        nameCtrl.text = displayName ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Nombre')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final error = await authService.updateProfile(nameCtrl.text);
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Perfil actualizado')));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
