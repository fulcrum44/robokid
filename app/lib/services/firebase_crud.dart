import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore usersDB = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getUsers() async {
  List<Map<String, dynamic>> users = [];

  QuerySnapshot query = await usersDB
      .collection("Proyectos")
      .get();

  for (var documento in query.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    users.add({
      "id": documento.id,
      "name": data['name'],
      "last_name": data['last_name'],
      "email": data['email'],
      "vinculado_Google": data['vinculado_Google'],
    });
  }

  return users;
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) async {
  DocumentReference<Map<String, dynamic>> collectionReferenceUser = usersDB.collection('Usuarios').doc(userId);

  return await collectionReferenceUser.get();
}

Future<void> insertUsuario(
  String uid,
  String? name,
  String? lastName,
  String? email, {
  bool vinculadoGoogle = false,
}) async {
  await usersDB.collection("Usuarios").doc(uid).set({
    "name": name,
    "last_name": lastName,
    "email": email,
    "vinculado_Google": vinculadoGoogle,
  });
}

Future<bool> checkEmailExists(String email) async {
  QuerySnapshot query = await usersDB
      .collection("Usuarios")
      .where("email", isEqualTo: email)
      .get();
  return query.docs.isNotEmpty;
}

Future<bool> isUserLinkedToGoogle(String email) async {
  QuerySnapshot query = await usersDB
      .collection("Usuarios")
      .where("email", isEqualTo: email)
      .get();

  if (query.docs.isNotEmpty) {
    final data = query.docs.first.data() as Map<String, dynamic>;
    return data['vinculado_Google'] ?? false;
  }
  return false;
}

Future<void> updateLinkStatus(String uid, bool status) async {
  await usersDB.collection("Usuarios").doc(uid).update({"vinculado_Google": status});
}

Future<void> updateUser(
  String uid,
  String? newName,
  String? newLastName,
) async {
  await usersDB.collection("Usuarios").doc(uid).update({
    if (newName != null) "name": newName,
    if (newLastName != null) "last_name": newLastName,
  });
}

Future<void> deleteUser(String uid) async {
  await usersDB.collection("Usuarios").doc(uid).delete();
}
