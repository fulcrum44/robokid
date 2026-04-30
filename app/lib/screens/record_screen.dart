import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/services/firebase_proyectos.dart';
import 'package:robokid/widgets/widgets.dart';

class RecordScreen extends StatefulWidget {
  final void Function(String proyectoId)? onOpenProject;
  const RecordScreen({super.key, this.onOpenProject});

  @override
  State<RecordScreen> createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  late Future<List<Map<String, dynamic>>> _futureProjects;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  /// Recarga la lista de proyectos (puede llamarse desde fuera con una GlobalKey)
  void reload() {
    setState(() => _loadProjects());
  }

  void _loadProjects() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _futureProjects = getUserProjects(uid);
    } else {
      _futureProjects = Future.value([]);
    }
  }

  // formatea un Timestamp de Firestore a dd/MM/yyyy
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showProjectDetails(Map<String, dynamic> project) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: project['nombre'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          project['nombre'] ?? 'Sin nombre',
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
                    text: _formatDate(project['creadoEn']),
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
                    text: _formatDate(project['actualizadoEn']),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
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
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != project['nombre']) {
                await projectRename(project['id'], newName);
                setState(() => _loadProjects());
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar nombre'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(String id) async {
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
      setState(() => _loadProjects());
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
                future: _futureProjects,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar proyectos'));
                  }

                  final projects = snapshot.data ?? [];

                  if (projects.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay proyectos guardados',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          iconColor: theme.iconTheme.color,
                          textColor: theme.textTheme.titleMedium?.color,
                          title: Text(
                            project['nombre'] ?? 'Sin nombre',
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
                                      ' ${_formatDate(project['creadoEn'])} ',
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
                                    _deleteProject(project['id']),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cloud_download_outlined,
                                  size: 24,
                                ),
                                onPressed: () {
                                  // abre el proyecto en el editor de bloques
                                  if (widget.onOpenProject != null) {
                                    widget.onOpenProject!(project['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () => _showProjectDetails(project),
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
