import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:robokid/services/firebase_crud.dart';


class FirebaseServices {

  static FirebaseAuth auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const String _webClientId =
      '79447508615-r7l8ojfqbq1fef0erm95fbbgaguktn4k.apps.googleusercontent.com';
  
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
      await _googleSignIn.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> googleLogin(BuildContext context) async {
    try {

      await _googleSignIn.signOut();

      await _googleSignIn.initialize(serverClientId: _webClientId);
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      if (await checkEmailExists(googleUser.email)) {
        if (!(await isUserLinkedToGoogle(googleUser.email))) {
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Correo ya registrado'),
                content: const Text(
                  'Este correo ya tiene cuenta con contraseña.\n'
                  'Inicia sesión normalmente y vincula Google desde Ajustes.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          }
          return null;
        }
      }

      final result = await auth.signInWithCredential(credential);
      return result.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      debugPrint('googleLogin error: $e');
      return null;
    } catch (e) {
      debugPrint('googleLogin error: $e');
      return null;
    }
  }

  // vincular Google a cuenta existente
  Future<void> linkGoogleAccount(BuildContext context) async {
    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final currentUser = auth.currentUser;
      if (currentUser == null) return;

      await currentUser.linkWithCredential(credential);
      await updateLinkStatus(currentUser.uid, true);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}