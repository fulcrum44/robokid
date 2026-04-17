import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<void> insertUsuario(
  String uid,
  String? name,
  String? email,
  String? lastName,
) async {
  await db.collection("Usuarios").doc(uid).set({
    "name": name,
    "last_name": lastName,
    "email": email,
  });
}
