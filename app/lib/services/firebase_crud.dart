import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore usersDB = FirebaseFirestore.instance;

Future<Map<String, dynamic>?> getIUser(String userId) async {
  final doc = await usersDB.collection("Usuarios").doc(userId).get();
  
  if (!doc.exists) return null;

  final userData = doc.data() as Map<String, dynamic>;

  return {
    "uid" : doc.id,
    "email" : userData['email'],
    "name" : userData['name'],
    "last_name" : userData['last_name'],
  };

}

Future<void> insertUsuario(
  String uid,
  String? name,
  String? email,
  String? lastName,
) async {
  await usersDB.collection("Usuarios").doc(uid).set({
    "name": name,
    "last_name": lastName,
    "email": email,
  });
}

Future<void> updateUser(
  String uid,
  String? newName,
  String? newEmail,
  String? newLastName,
) async {
  await usersDB.collection("Usuarios").doc(uid).update({
    "name": newName,
    "last_name": newLastName,
    "email": newEmail,
  });
}

  Future<void> deleteUser(String uid) async {
  await usersDB.collection("Usuarios").doc(uid).delete();
}
