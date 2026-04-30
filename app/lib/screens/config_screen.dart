import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/theme/app_theme.dart';
import 'package:robokid/widgets/widgets.dart';
import 'package:robokid/services/firebase_services.dart';
import 'package:robokid/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  // Tema seleccionado, por defecto sigue el sistema
  String _selectedTheme = 'system';

  // Nombre y apellido por separado para poder editarlos individualmente
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    // Cargamos el tema y el nombre al entrar a la pantalla
    _loadCurrentTheme();
    _loadUserName();
  }

  // Leemos el tema guardado en el almacenamiento del teléfono
  void _loadCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'system';
    });
  }

  // Partimos el displayName en nombre y apellido
  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      final parts = user!.displayName!.split(' ');
      _firstNameController.text = parts.isNotEmpty ? parts.first : '';
      _lastNameController.text = parts.length > 1
          ? parts.sublist(1).join(' ')
          : '';
    }
  }

  @override
  void dispose() {
    // Liberamos los controllers al salir de la pantalla
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Guarda el nombre en Firebase y muestra confirmación
  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    try {
      if (user != null &&
          (_firstNameController.text.isNotEmpty ||
              _lastNameController.text.isNotEmpty)) {
        // Concatenamos nombre y apellido hasta que Firestore los guarde por separado
        final fullName =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                .trim();
        await user.updateDisplayName(fullName);
      }

      if (mounted) {
        CustomSnackBar.showSnackBar(
          "Configuración actualizada",
          context,
          theme,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showSnackBar("Error al guardar: $e", context, theme);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    // Si no hay usuario es que está en modo invitado
    final bool isGuest = user == null;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          // stretch para que el título centrado ocupe todo el ancho
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Configuración',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 32,
                color: AppTheme.primaryText(isDark),
              ),
            ),
            const SizedBox(height: 20),

            // Sección de perfil: distinto contenido según si hay sesión o no
            _buildSectionCard(
              theme,
              isDark: isDark,
              title: 'Perfil del Usuario',
              icon: Icons.person_outline,
              children: [
                if (isGuest) ...[
                  // Avisamos al invitado de que no tiene sesión
                  Text(
                    "No has iniciado sesión. Regístrate para guardar tus proyectos en la nube.",
                    style: TextStyle(
                      color: AppTheme.secondaryText(isDark),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Navegamos a login o registro según lo que elija
                  CustomRegisterButton(
                    theme: theme,
                    content: const Text("Iniciar sesión"),
                    onPressed: () => Navigator.pushNamed(context, 'login'),
                  ),
                  const SizedBox(height: 10),
                  CustomRegisterButton(
                    theme: theme,
                    content: const Text("Registrarse"),
                    onPressed: () => Navigator.pushNamed(context, 'signup'),
                  ),
                ] else ...[
                  // Campos editables de nombre y apellido
                  LoginFormWidget(
                    hintText: 'Nombre',
                    icon: Icons.person_outline,
                    enabled: true,
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: 10),
                  LoginFormWidget(
                    hintText: 'Apellido',
                    icon: Icons.person_outline,
                    enabled: true,
                    controller: _lastNameController,
                  ),
                  const SizedBox(height: 10),
                  // El email no se puede editar, solo se muestra
                  LoginFormWidget(
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    enabled: false,
                    controller: TextEditingController(text: user.email),
                  ),
                  const SizedBox(height: 15),
                  // Para vincular una cuenta Google a un usuario registrado con email
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: AppTheme.dividerColor(isDark)),
                    ),
                    icon: const Icon(Icons.link, color: Colors.blue),
                    label: Text(
                      'Vincular con Google',
                      style: TextStyle(color: AppTheme.primaryText(isDark)),
                    ),
                    onPressed: () => CustomSnackBar.showSnackBar(
                      "Próximamente",
                      context,
                      theme,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 15),

            // Sección para cambiar entre modo claro, oscuro o sistema
            _buildSectionCard(
              theme,
              isDark: isDark,
              title: 'Apariencia',
              icon: Icons.palette_outlined,
              children: [
                Text(
                  "Elige cómo quieres ver la aplicación",
                  style: TextStyle(
                    color: AppTheme.secondaryText(isDark),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTheme,
                  dropdownColor: AppTheme.cardBackground(isDark),
                  style: TextStyle(color: AppTheme.primaryText(isDark)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.inputFill(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(
                        "Usar ajuste del teléfono",
                        style: TextStyle(color: AppTheme.primaryText(isDark)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'light',
                      child: Text(
                        "Modo Claro",
                        style: TextStyle(color: AppTheme.primaryText(isDark)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dark',
                      child: Text(
                        "Modo Oscuro",
                        style: TextStyle(color: AppTheme.primaryText(isDark)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    _updateAppTheme(value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // El botón de cerrar sesión solo aparece si hay sesión activa
            if (!isGuest) _buildActionList(),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.robokids,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveSettings,
                child: const Text(
                  "GUARDAR CAMBIOS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Guarda el tema en SharedPreferences y lo aplica
  void _updateAppTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode);

    if (mode == 'system') MyApp.themeNotifier.value = ThemeMode.system;
    if (mode == 'light') MyApp.themeNotifier.value = ThemeMode.light;
    if (mode == 'dark') MyApp.themeNotifier.value = ThemeMode.dark;

    if (mode == 'system' && mounted) {
      CustomSnackBar.showSnackBar(
        "Sincronizado con el sistema",
        context,
        Theme.of(context),
      );
    }
  }

  // Widget reutilizable para las secciones con título, icono y contenido
  Widget _buildSectionCard(
    ThemeData theme, {
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.robokids),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryText(isDark),
                ),
              ),
            ],
          ),
          Divider(color: AppTheme.dividerColor(isDark), height: 25),
          ...children,
        ],
      ),
    );
  }

  // Fondo transparente para que se vea igual en claro y oscuro
  Widget _buildActionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text(
          "Cerrar Sesión",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          await FirebaseServices().logout();
          // Volvemos al login tras cerrar sesión gracias al StreamBuilder del Wrapper
        },
      ),
    );
  }
}
