import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class FirebaseServices {
  Future<User?> login({required String email, required String password}) async {
    try {
      //con esto intentamos ahcer un inicio de sesion con el autentificacion de firebase
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si lo conseguimos porque somos unos maquinas; nos devulve las credenciales del usuario
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      //con esto intentamos crear un usuario con el autentificacion de firebase
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si lo conseguimos porque somos unos maquinas; nos devulve las credenciales del usuario
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
