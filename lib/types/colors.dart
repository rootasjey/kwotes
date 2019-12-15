import 'package:flutter/material.dart';

class ThemeColor extends ChangeNotifier {
  static Color primary = Color(0xFF706FD3);
  static Color secondary = Color(0xFFF56498);
  static Color validation = Color(0xFF02ECC7);
  static Color success = Color(0xFF2ECC71);
  static Color error = Color(0xFFE74C3C);

  Color prime = Color(0xFF706FD3);

  void updatePrimary(String topic) {
    final Color color = topicColor(topic);
    prime = color;
    notifyListeners();
  }

  Map<int, Color> swatchColor() {
    Map<int, Color> accentSwatchColor = {
      50: Color.fromRGBO(prime.red, prime.green, prime.blue, .1),
      100: Color.fromRGBO(prime.red, prime.green, prime.blue, .2),
      200: Color.fromRGBO(prime.red, prime.green, prime.blue, .3),
      300: Color.fromRGBO(prime.red, prime.green, prime.blue, .4),
      400: Color.fromRGBO(prime.red, prime.green, prime.blue, .5),
      500: Color.fromRGBO(prime.red, prime.green, prime.blue, .6),
      600: Color.fromRGBO(prime.red, prime.green, prime.blue, .7),
      700: Color.fromRGBO(prime.red, prime.green, prime.blue, .8),
      800: Color.fromRGBO(prime.red, prime.green, prime.blue, .9),
      900: Color.fromRGBO(prime.red, prime.green, prime.blue, 1),
    };

    return accentSwatchColor;
  }

  MaterialColor materialColor() {
    return MaterialColor(prime.value, swatchColor());
  }

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

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
