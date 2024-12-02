import 'package:flutter/material.dart';

Widget myButton({required VoidCallback action, required String label}) {
  return ElevatedButton(
    onPressed: action,
    style: const ButtonStyle(),
    child: Text(label),
  );
}
