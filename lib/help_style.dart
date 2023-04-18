import 'package:flutter/material.dart';

const _themeColor = Colors.lightGreen;

class HelpStyle {
  static TextStyle get titleStyle {
    return const TextStyle(color: Colors.black, fontSize: 20);
  }

  static TextStyle get contextStyle {
    return const TextStyle(color: Colors.black54, fontSize: 16);
  }

  static TextStyle get ptitleStyle {
    return const TextStyle(color: _themeColor, fontSize: 12);
  }

  static TextStyle get pcontextStyle {
    return const TextStyle(color: _themeColor, fontSize: 12);
  }

  static get primarycolor => _themeColor;
  static get cellMargin => 8.0;
  static get margin => 12.0;
  static get boxshadow => BoxDecoration(
        boxShadow: const [
          BoxShadow(
            // color: Color(0xf8f8f8),
            blurRadius: 3.0,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffffffff),
      );
}
