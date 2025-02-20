import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", ""); // Remove '#' if present

  if (hex.length == 6) {
    hex = "FF$hex"; // Add full opacity if alpha is missing
  }

  return Color(int.parse(hex, radix: 16));
}