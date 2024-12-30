import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Gestionar Usuarios (Admin)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data()! as Map<String, dynamic>;
              final uid = data['uid'];
              final email = data['email'];
              final displayName = data['displayName'] ?? '';

              return ListTile(
                title: Text('$displayName ($email)'),
                subtitle: Text('UID: $uid'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        String? newName = await showDialog(
                            context: context,
                            builder: (_) {
                              final ctrl =
                                  TextEditingController(text: displayName);
                              return AlertDialog(
                                title: Text('Editar nombre'),
                                content: TextField(controller: ctrl),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, ctrl.text),
                                      child: Text('Guardar')),
                                ],
                              );
                            });
                        if (newName != null) {
                          await authService.updateOtherUser(uid, newName);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Elimina de firestore
                        await authService.deleteUser(uid);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
