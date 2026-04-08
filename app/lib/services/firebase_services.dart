import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class FirebaseServices {
  Future<User?> login({required String email, required String password}) async {
    try {
      //con esto intentamos ahcer un inicio de sesion con el autentificacion de firebase
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si lo conseguimos porque somos unos maquinas; nos devulve las credenciales del usuario
      return credential.user;
    } on FirebaseAuthException catch (e) {
      //Si hay un error porque no encontro al usuario; no salta el siguiente print
      if (e.code == 'user-not-found') {
        print('No se encontró un usuario con ese correo.');
        //Si hay un error porque la contraseña es incorrecta; no salta el siguiente print
      } else if (e.code == 'wrong-password') {
        print('La contraseña es incorrecta.');
      } else {
        print('Error de Firebase: ${e.message}');
      }
      //Si falla; devolvemos niull
      return null;
    } catch (e) {
      print('Error que no se esperaba ni el firebase: $e');
      return null;
    }
  }
   Future<User?> createUser({required String email, required String password}) async {
    try {
      //con esto intentamos ahcer un inicio de sesion con el autentificacion de firebase
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si lo conseguimos porque somos unos maquinas; nos devulve las credenciales del usuario
      return credential.user;
    } on FirebaseAuthException catch (e) {
      //Si hay un error porque no encontro al usuario; no salta el siguiente print
      if (e.code == 'email-already-in-use') {
        print('No se encontró un usuario con ese correo.');
        //Si hay un error porque la contraseña es incorrecta; no salta el siguiente print
      } else if (e.code == 'weak-password') {
        print('La contraseña es incorrecta.');
      } else {
        print('Error de Firebase: ${e.message}');
      }
      //Si falla; devolvemos niull
      return null;
    } catch (e) {
      print('Error que no se esperaba ni el firebase: $e');
      return null;
    }
  }
}
