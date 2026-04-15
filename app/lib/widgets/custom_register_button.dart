import 'package:flutter/material.dart';
import 'package:robokid/theme/app_theme.dart';

class CustomRegisterButton extends StatelessWidget {
  final ThemeData theme;
  final Widget content;
  final VoidCallback? onPressed;

  const CustomRegisterButton({super.key, required this.theme, required this.content, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.055,
      child: ElevatedButton(
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.all(AppTheme.robokids),
        ),
        onPressed: onPressed,

        child: content
      ),
    );
  }
}