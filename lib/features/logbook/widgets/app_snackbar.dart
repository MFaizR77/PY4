import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

void showAppSnackbar(BuildContext context, String message, SnackbarType type) {
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackbarType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackbarType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case SnackbarType.info:
      backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
