import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getIUser() async {
  List user = [];

  CollectionReference collectionReferenceUser = db.collection('Usuarios');

  QuerySnapshot queryUser = await collectionReferenceUser.get();

  for (var documento in queryUser.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    final userMap = {
      "email": data['email'],
      "name": data['name'],
      "last_name": data['last_name'],
      "uid": documento.id,
    };
    user.add(userMap);
  }

  return user;
}

Future<void> insertUsuario(
  String uid,
  String? name,
  String? email,
  String? lastName, {
  bool vinculadoGoogle = false,
}) async {
  await db.collection("Usuarios").doc(uid).set({
    "name": name,
    "last_name": lastName,
    "email": email,
    "vinculado_Google": vinculadoGoogle,
  });
}

Future<bool> checkEmailExists(String email) async {
  QuerySnapshot query = await db
      .collection("Usuarios")
      .where("email", isEqualTo: email)
      .get();
  return query.docs.isNotEmpty;
}

Future<bool> isUserLinkedToGoogle(String email) async {
  QuerySnapshot query = await db
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
  await db.collection("Usuarios").doc(uid).update({"vinculado_Google": status});
}

Future<void> updateUser(
  String uid,
  String? newName,
  String? newLastName,
) async {
  await db.collection("Usuarios").doc(uid).set({
    if (newName != null) "name": newName,
    if (newLastName != null) "last_name": newLastName,
  });
}

Future<void> deleteUser(String uid) async {
  await db.collection("Usuarios").doc(uid).delete();
}
