import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore projectsDB = FirebaseFirestore.instance;

// guarda un proyecto nuevo en Firestore y devuelve el id que se genera
Future<String> insertProyecto(
  String userId,
  String nombre,
  String workspaceJson,
  String codigoArduino,
) async {
  final doc = await projectsDB.collection("Proyectos").add({
    "userId": userId,
    "nombre": nombre,
    "workspaceJson": workspaceJson,
    "codigoArduino": codigoArduino,
    "creadoEn": Timestamp.now(),
    "actualizadoEn": Timestamp.now(),
  });

  return doc.id;
}

// trae todos los proyectos de un usuario ordenados por fecha
Future<List<Map<String, dynamic>>> getUserProjects(String userId) async {
  List<Map<String, dynamic>> proyectos = [];

  QuerySnapshot query = await projectsDB
      .collection("Proyectos")
      .where("userId", isEqualTo: userId)
      .orderBy("actualizadoEn", descending: true)
      .get();

  for (var documento in query.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    proyectos.add({
      "id": documento.id,
      "nombre": data['nombre'],
      "workspaceJson": data['workspaceJson'],
      "codigoArduino": data['codigoArduino'],
      "creadoEn": data['creadoEn'],
      "actualizadoEn": data['actualizadoEn'],
    });
  }

  return proyectos;
}

// trae un proyecto por su id
Future<Map<String, dynamic>?> getProyecto(String projectId) async {
  final doc = await projectsDB.collection("Proyectos").doc(projectId).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;
  return {
    "id": doc.id,
    "nombre": data['nombre'],
    "workspaceJson": data['workspaceJson'],
    "codigoArduino": data['codigoArduino'],
    "creadoEn": data['creadoEn'],
    "actualizadoEn": data['actualizadoEn'],
  };
}

// actualiza el workspace y el codigo de un proyecto que ya existe
Future<void> updateProyecto(
  String projectId,
  String workspaceJson,
  String codigoArduino,
) async {
  await projectsDB.collection("Proyectos").doc(projectId).update({
    "workspaceJson": workspaceJson,
    "codigoArduino": codigoArduino,
    "actualizadoEn": Timestamp.now(),
  });
}

Future<void> deleteProyecto(String projectId) async {
  await projectsDB.collection("Proyectos").doc(projectId).delete();
}

// renombra un proyecto
Future<void> projectRename(String projectId, String nuevoNombre) async {
  await projectsDB.collection("Proyectos").doc(projectId).update({
    "nombre": nuevoNombre,
    "actualizadoEn": Timestamp.now(),
  });
}
