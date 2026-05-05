import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:robokid/services/firebase_crud.dart';


class FirebaseServices {

  static FirebaseAuth auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isGoogleInitialized = false;

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

  Future<void> initGoogleSignIn() async {
    if (!isGoogleInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '79447508615-r7l8ojfqbq1fef0erm95fbbgaguktn4k.apps.googleusercontent.com'
      );
    }
    isGoogleInitialized = true;
  }

  Future<UserCredential?> googleLogin(BuildContext context) async {
    try {
      await initGoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final bool emailExists = await checkEmailExists(googleUser.email);
      final bool googleLinked = await isUserLinkedToGoogle(googleUser.email);

      if (emailExists && !googleLinked) {
        await _googleSignIn.signOut();
        throw FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          email: googleUser.email,
          message: 'Ya existe una cuenta con este correo usando email/password.',
        );
      }

      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization =
          await authorizationClient.authorizationForScopes(['email', 'profile']);

      if (authorization?.accessToken == null) {
        authorization = await authorizationClient
            .authorizationForScopes(['email', 'profile']);
        if (authorization?.accessToken == null) {
          throw FirebaseAuthException(
            code: 'google-auth-failed',
            message: 'No se pudo obtener el access token.',
          );
        }
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization!.accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        final userDoc = await getUser(user.uid);
        if (!userDoc.exists) {
          await insertUsuario(
            user.uid,
            user.displayName ?? '',
            user.email,
            user.displayName ?? '',
            vinculadoGoogle: true,
          );
        }
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      rethrow;
    } on GoogleSignInException catch (e) {
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  // vincular Google a cuenta existente
  Future<void> linkGoogleAccount(BuildContext context) async {
    try {
      initGoogleSignIn();
      
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

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