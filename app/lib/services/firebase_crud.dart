import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore usersDB = FirebaseFirestore.instance;

Future<List> getIUser() async {
  List user = [];

  CollectionReference collectionReferenceUser = usersDB.collection(
    'Usuarios',
  );

  QuerySnapshot queryUser = await collectionReferenceUser.get();
  
  queryUser.docs.forEach((documento) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    final userMap = {
      "email" : data['email'],
      "name" : data['name'],
      "last_name" : data['last_name'],
      "uid" : documento.id,
    };
    user.add(userMap);
  });

  return user;
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
  await usersDB.collection("Usuarios").doc(uid).set({
    "name": newName,
    "last_name": newLastName,
    "email": newEmail,
  });
}

  Future<void> deleteUser(String uid) async {
  await usersDB.collection("Usuarios").doc(uid).delete();
}
