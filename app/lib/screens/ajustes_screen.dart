import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/theme/app_theme.dart';
import 'package:robokid/widgets/widgets.dart';
import 'package:robokid/services/firebase_services.dart';
import 'package:robokid/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  String _selectedTheme = 'system';
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');

    // Cargamos la preferencia al entrar a la pantalla
    _loadCurrentTheme();
  }

  // Función para leer qué tema está guardado en la memoria del teléfono
  void _loadCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'system';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    try {
      if (user != null && _nameController.text.isNotEmpty) {
        await user.updateDisplayName(_nameController.text);
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
    final bool isGuest = user == null;

    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardBackground = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final Color primaryTextColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.grey : Colors.black54;
    final Color dividerColor = isDark ? Colors.white24 : Colors.black12;
    final Color inputFillColor = isDark
        ? Colors.white10
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 32,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              theme,
              title: 'Perfil del Usuario',
              icon: Icons.person_outline,
              cardColor: cardBackground,
              textColor: primaryTextColor,
              dividerCol: dividerColor,
              children: [
                if (isGuest) ...[
                  Text(
                    "No has iniciado sesión. Regístrate para guardar tus proyectos en la nube.",
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: dividerColor),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      color: Colors.red,
                      size: 30,
                    ),
                    label: Text(
                      'Registrarse con Google',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    onPressed: () => CustomSnackBar.showSnackBar(
                      "Próximamente",
                      context,
                      theme,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomRegisterButton(
                    theme: theme,
                    content: const Text("Registrarse"),
                    onPressed: () =>
                        Navigator.pushNamed(context, 'registerUser'),
                  ),
                ] else ...[
                  LoginFormWidget(
                    hintText: 'Nombre',
                    icon: Icons.person_outline,
                    enabled: true,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 10),
                  LoginFormWidget(
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    enabled: false,
                    controller: TextEditingController(text: user.email),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: dividerColor),
                    ),
                    icon: const Icon(Icons.link, color: Colors.blue),
                    label: Text(
                      'Vincular otra cuenta Google',
                      style: TextStyle(color: primaryTextColor),
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

            _buildSectionCard(
              theme,
              title: 'Apariencia',
              icon: Icons.palette_outlined,
              cardColor: cardBackground,
              textColor: primaryTextColor,
              dividerCol: dividerColor,
              children: [
                Text(
                  "Elige cómo quieres ver la aplicación:",
                  style: TextStyle(color: secondaryTextColor, fontSize: 13),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTheme,
                  dropdownColor: cardBackground,
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFillColor,
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
                        style: TextStyle(color: primaryTextColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'light',
                      child: Text(
                        "Modo Claro",
                        style: TextStyle(color: primaryTextColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dark',
                      child: Text(
                        "Modo Oscuro",
                        style: TextStyle(color: primaryTextColor),
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

            if (!isGuest) _buildActionList(theme, cardBackground),

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

  void _updateAppTheme(String mode) async {
    // guardamos la preferencia físicamente en el teléfono
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode);

    if (mode == 'system') MyApp.themeNotifier.value = ThemeMode.system;
    if (mode == 'light') MyApp.themeNotifier.value = ThemeMode.light;
    if (mode == 'dark') MyApp.themeNotifier.value = ThemeMode.dark;

    if (mounted) {
      final Color snackBarContentColor = (mode == 'light')
          ? Colors.black
          : Colors.white;
      final Color snackBarBgColor = (mode == 'light')
          ? Colors.white
          : Colors.grey[900]!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (mode == 'system')
                ? "Sincronizado con el sistema"
                : "Modo $mode activado",
            style: TextStyle(color: snackBarContentColor),
          ),
          backgroundColor: snackBarBgColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    required Color cardColor,
    required Color textColor,
    required Color dividerCol,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  color: textColor,
                ),
              ),
            ],
          ),
          Divider(color: dividerCol, height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionList(ThemeData theme, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
          if (mounted) Navigator.pushReplacementNamed(context, 'login');
        },
      ),
    );
  }
}
