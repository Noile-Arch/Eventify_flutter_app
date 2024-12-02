import 'package:eventify_app/config/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget myCustomText(
    {required text, required double size, Color color = text1}) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: size),
  );
}
