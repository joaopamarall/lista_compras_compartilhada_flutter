import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  // Verifica se o usuário está logado
  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Método para registrar um novo usuário
  Future<void> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro no registro: $e');
      }
      rethrow;
    }
  }

  // Método para login de usuário
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro no login: $e');
      }
      rethrow;
    }
  }

  // Método para logout do usuário
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro no logout: $e');
      }
      rethrow;
    }
  }

  // Método para redefinir senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao enviar redefinição de senha: $e');
      }
      rethrow;
    }
  }
}
