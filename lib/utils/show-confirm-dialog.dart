import 'package:flutter/material.dart';

Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String cancelText = 'Huỷ',
  String confirmText = 'Xác nhận',
  bool isDanger = false,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              confirmText,
              style: TextStyle(color: isDanger ? Colors.red : Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}
