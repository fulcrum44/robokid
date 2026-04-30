import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/services/firebase_proyectos.dart';
import 'package:robokid/widgets/widgets.dart';

class RecordScreen extends StatefulWidget {
  final void Function(String proyectoId)? onAbrirProyecto;
  const RecordScreen({super.key, this.onAbrirProyecto});

  @override
  State<RecordScreen> createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  late Future<List<Map<String, dynamic>>> _futureProyectos;

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  /// Recarga la lista de proyectos (puede llamarse desde fuera con una GlobalKey)
  void recargar() {
    setState(() => _cargarProyectos());
  }

  void _cargarProyectos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _futureProyectos = getProyectosUsuario(uid);
    } else {
      _futureProyectos = Future.value([]);
    }
  }

  // formatea un Timestamp de Firestore a dd/MM/yyyy
  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return '';
    final fecha = (timestamp as Timestamp).toDate();
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  void _mostrarDetallesProyecto(Map<String, dynamic> proyecto) {
    final theme = Theme.of(context);
    final nombreController = TextEditingController(
      text: proyecto['nombre'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          proyecto['nombre'] ?? 'Sin nombre',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Creado el: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _formatearFecha(proyecto['creadoEn']),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Última modificación: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _formatearFecha(proyecto['actualizadoEn']),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del proyecto',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () async {
              final nuevoNombre = nombreController.text.trim();
              if (nuevoNombre.isNotEmpty && nuevoNombre != proyecto['nombre']) {
                await renombrarProyecto(proyecto['id'], nuevoNombre);
                setState(() => _cargarProyectos());
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar nombre'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarProyecto(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text('¿Seguro que quieres eliminar este proyecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await deleteProyecto(id);
      setState(() => _cargarProyectos());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Historial',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureProyectos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar proyectos'));
                  }

                  final proyectos = snapshot.data ?? [];

                  if (proyectos.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay proyectos guardados',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: proyectos.length,
                    itemBuilder: (context, index) {
                      final proyecto = proyectos[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          iconColor: theme.iconTheme.color,
                          textColor: theme.textTheme.titleMedium?.color,
                          title: Text(
                            proyecto['nombre'] ?? 'Sin nombre',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text.rich(
                            TextSpan(
                              style: theme.textTheme.titleSmall,
                              children: [
                                TextSpan(
                                  text: 'Creado el:',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' ${_formatearFecha(proyecto['creadoEn'])} ',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 24,
                                ),
                                onPressed: () =>
                                    _eliminarProyecto(proyecto['id']),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cloud_download_outlined,
                                  size: 24,
                                ),
                                onPressed: () {
                                  // abre el proyecto en el editor de bloques
                                  if (widget.onAbrirProyecto != null) {
                                    widget.onAbrirProyecto!(proyecto['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () => _mostrarDetallesProyecto(proyecto),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
