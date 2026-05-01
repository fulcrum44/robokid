import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robokid/screens/screens.dart';

import '../providers/auth_provider.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  String? _projectId; // id del proyecto que se va a abrir en BlockScreen
  final _recordKey = GlobalKey<RecordScreenState>();

  // cuando el usuario toca un proyecto en el historial, cambiamos a la tab de bloques
  void _openProject(String proyectoId) {
    setState(() {
      _projectId = proyectoId;
      _selectedIndex = 0; // vamos a la tab de bloques
    });
  }

  void _onItemTapped(int index) {
    // si cambiamos de tab manualmente, limpiamos el proyecto para no recargarlo
    if (index != 0) {
      _projectId = null;
    }
    // si vamos al historial, recargamos los proyectos
    if (index == 1) {
      _recordKey.currentState?.reload();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>(); 
    // Si no hay usuario es que está en modo invitado
    final bool isGuest = auth.isGuest;

    // no usamos const porque BlockScreen cambia segun el proyecto
    final screens = <Widget>[
      BlockScreen(proyectoId: _projectId),
      if (!isGuest) RecordScreen(key: _recordKey, onOpenProject: _openProject),
      const ConfigScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            label: 'Bloques',
          ),
          
          if (!isGuest)
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: 'Historial',
            ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
