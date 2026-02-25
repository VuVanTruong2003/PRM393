import 'package:flutter/material.dart';

class AppUI {
  AppUI._();

  static const radius12 = BorderRadius.all(Radius.circular(12));
  static const radius16 = BorderRadius.all(Radius.circular(16));
  static const radius20 = BorderRadius.all(Radius.circular(20));

  static const pagePadding = EdgeInsets.all(16);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2F80ED),
      Color(0xFF1F62C8),
    ],
  );

  static const softBg = Color(0xFFF3F6FB);

  static const pastelGreen = Color(0xFFEAF7EE);
  static const pastelBlue = Color(0xFFEAF2FF);
  static const pastelOrange = Color(0xFFFFF3E6);
  static const pastelPurple = Color(0xFFF2ECFF);

  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: radius16,
      boxShadow: const [
        BoxShadow(
          blurRadius: 18,
          spreadRadius: 0,
          offset: Offset(0, 10),
          color: Color(0x14000000),
        ),
      ],
    );
  }
}

