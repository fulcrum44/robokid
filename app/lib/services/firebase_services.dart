import 'package:firebase_auth/firebase_auth.dart';


class FirebaseServices {
  static FirebaseAuth auth = FirebaseAuth.instance;
  
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
    required String nombre, // Añadimos el nombre como parámetro obligatorio
  }) async {
    try {
      //con esto intentamos crear un usuario con el autentificacion de firebase
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(nombre);
      
      // recargamos el usuario para que la app sepa que ya tiene nombre
      await credential.user?.reload();

      // Si lo conseguimos porque somos unos maquinas; nos devuelve el usuario actualizado
      return auth.currentUser; 
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}