import 'package:flutter/material.dart';
import 'package:robokid/screens/screens.dart';

class NavegationScreen extends StatefulWidget {
  const NavegationScreen({super.key});

  @override
  State<NavegationScreen> createState() => _NavegationScreenState();
}

class _NavegationScreenState extends State<NavegationScreen> {
  int _selectedIndex = 0;
  String? _proyectoId; // id del proyecto que se va a abrir en BlockScreen

  // cuando el usuario toca un proyecto en el historial, cambiamos a la tab de bloques
  void _abrirProyecto(String proyectoId) {
    setState(() {
      _proyectoId = proyectoId;
      _selectedIndex = 0; // vamos a la tab de bloques
    });
  }

  void _onItemTapped(int index) {
    // si cambiamos de tab manualmente, limpiamos el proyecto para no recargarlo
    if (index != 0) {
      _proyectoId = null;
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
    // no usamos const porque BlockScreen cambia segun el proyecto
    final screens = <Widget>[
      BlockScreen(proyectoId: _proyectoId),
      RecordScreen(onAbrirProyecto: _abrirProyecto),
      const AjustesScreen(),
    ];

    return Scaffold(
     body: IndexedStack( index: _selectedIndex, children: screens, ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            label: 'Bloques',
          ),
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
