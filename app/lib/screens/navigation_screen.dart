import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robokid/screens/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  String? _projectId; // id del proyecto que se va a abrir en BlockScreen
  String _themeMode = 'system';
  final _recordKey = GlobalKey<RecordScreenState>();

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // cuando el usuario toca un proyecto en el historial, cambiamos a la tab de bloques
  void _openProject(String proyectoId) {
    setState(() {
      _projectId = proyectoId;
      _selectedIndex = 0; // vamos a la tab de bloques
    });
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getString('theme') ?? 'system';
    });
  }

  Future<void> _changeThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode);
    setState(() {
      _themeMode = mode;
    });
  }

  // Resuelve 'system' al tema real
  String _systemTheme(BuildContext context) {
    if (_themeMode == 'system') {
      final brightness = MediaQuery.platformBrightnessOf(context);
      return brightness == Brightness.dark ? 'dark' : 'light';
    }
    return _themeMode;
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

    final theme = _systemTheme(context);

    // no usamos const porque BlockScreen cambia segun el proyecto
    final screens = <Widget>[
      BlockScreen(projectId: _projectId, themeMode: theme),
      if (!isGuest) RecordScreen(key: _recordKey, onOpenProject: _openProject),
      ConfigScreen(onChangeThemeMode: _changeThemeMode,  temaActual: _themeMode),
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
