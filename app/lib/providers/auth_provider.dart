import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/services/services.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true; // manejamos el tiempo de carga cuando el usuario hace login o logout

  bool get isGuest => _user == null || _user!.isAnonymous;
  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    FirebaseServices.auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }
}