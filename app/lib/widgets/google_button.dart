import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final String screen;
  final VoidCallback? onPressed;
  final TextStyle? textTheme;

  const GoogleButton({super.key, required this.screen, this.onPressed, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.red),
      label: Text(
        (screen == 'signup')
            ? 'Registrarse con Google'
            : ((screen == 'login')
                  ? 'Iniciar sesión con Google'
                  : 'Vincular cuenta Google'),
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}