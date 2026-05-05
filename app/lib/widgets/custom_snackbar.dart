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
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.7,
          right: 20,
          left: 20,
        ),
      ),
    );
  }
}