import 'package:flutter/material.dart';

class ThemeColor {
  static Color primary = Color(0xFF706FD3);
  static Color secondary = Color(0xFFF56498);
  static Color validation = Color(0xFF02ECC7);
  static Color success = Color(0xFF2ECC71);
  static Color error = Color(0xFFE74C3C);

  static Color topicColor(String topic) {
    switch (topic) {
      case 'feelings':
        return Color(0xFFE74C3C);
      case 'motivation':
        return Color(0xFF1E90FF);
      case 'fun':
        return Color(0xFFF5CD79);
      case 'reflexion':
        return Color(0xFFEA8685);
      case 'philosophy':
        return Color(0xFF574B90);
      case 'fact':
        return Color(0xFFF19066);
      case 'beliefs':
        return Color(0xFF303952);
      case 'poetry':
        return Color(0xFF546DE5);
      default:
        return primary;
    }
  }
}
