import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? user;
  bool isLoading = true;

  AuthService() {
    _checkLogin();
  }

  _checkLogin() {
    _auth.authStateChanges().listen((User? u) async {
      user = u;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<String?> signUp(
      String email, String password, String displayName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = cred.user;
      await _db.collection('users').doc(user!.uid).set({
        'uid': user!.uid,
        'email': email,
        'displayName': displayName,
        'role': 'user', // por defecto user
      });
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> updateProfile(String displayName) async {
    try {
      await _db
          .collection('users')
          .doc(user!.uid)
          .update({'displayName': displayName});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Esta función la puedes usar para saber si el usuario es admin
  Future<bool> isAdmin() async {
    if (user == null) return false;
    final doc = await _db.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      final role = doc.data()!['role'] as String;
      return role == 'admin';
    }
    return false;
  }

  // Funciones de admin para editar/eliminar otros usuarios
  Future<void> deleteUser(String uid) async {
    // Primero elimina el documento en Firestore
    await _db.collection('users').doc(uid).delete();
    // Opcionalmente, podrías eliminar la cuenta de auth,
    // pero Firebase no permite eliminar otro user con las credenciales de un user normal.
    // Esto se hace generalmente con Cloud Functions o desde el panel de admin.
  }

  Future<void> updateOtherUser(String uid, String displayName) async {
    await _db.collection('users').doc(uid).update({
      'displayName': displayName,
    });
  }
}
