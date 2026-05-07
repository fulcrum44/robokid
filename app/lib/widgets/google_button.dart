import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final String screen;
  final VoidCallback? onPressed;
  final TextStyle? textTheme;

  const GoogleButton({Key? key, required this.screen, this.onPressed, required this.textTheme})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
      label: Text(
        (screen == 'signup')
            ? 'Registrarse con Google'
            : ((screen == 'login')
                  ? 'Iniciar sesión con Google'
                  : 'Vincular cuenta Google'),
        style: textTheme,
      ),
    );
  }
}