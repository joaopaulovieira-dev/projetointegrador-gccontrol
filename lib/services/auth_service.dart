import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'local_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  void storeRefreshToken(String refreshToken) {
    LocalStorageService.saveRefreshToken(refreshToken);
  }

  Future<void> refreshToken() async {
    String? refreshToken = LocalStorageService.getRefreshToken();
    if (refreshToken != null && _auth.currentUser != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: refreshToken,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    LocalStorageService.clearRefreshToken();
  }

  // Método para obter o usuário atualmente autenticado
  Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }

    // Outros métodos do serviço de autenticação, como signIn, signOut, etc.
  }
}
