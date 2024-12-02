import 'package:flutter/material.dart';

import '../../config/colors.dart';

Widget textFieldWidget({
  required TextEditingController controller,
  String hint = "",
  IconData icon = Icons.person,
  bool isPassword = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: inputFill,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          icon,
          color: text2,
        ),
        suffixIcon: isPassword ? const Icon(Icons.visibility) : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide:
              BorderSide(color: Colors.deepPurple, width: 2.0), // Focus border
        ),
      ),
    ),
  );
}
