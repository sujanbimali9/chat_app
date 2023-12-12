import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
