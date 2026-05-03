import 'package:flutter/material.dart';

class CustomSnackBar {

  static void showSnackBar(String message, BuildContext context, ThemeData theme) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.titleMedium,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 20,
          right: 20,
          left: 20,
        ),
      ),
    );
  }
}