import "dart:math";

import "package:flutter/material.dart";
import "package:kwotes/types/topic.dart";

class ColorPalette {
  /// All necessary colors for the app.
  ColorPalette();

  final List<Color> foregroundPalette = [
    // const Color.fromRGBO(101, 40, 247, 1),
    // const Color.fromRGBO(160, 118, 249, 1),
    // const Color.fromRGBO(178, 164, 255, 1),
    // const Color.fromRGBO(215, 187, 245, 1),
    // const Color.fromRGBO(172, 188, 255, 1),
    // const Color.fromRGBO(174, 226, 255, 1),
    // const Color.fromRGBO(145, 200, 228, 1),
    // const Color.fromRGBO(230, 255, 253, 1),
    // const Color.fromRGBO(255, 195, 195, 1),
    // const Color.fromRGBO(254, 187, 204, 1),
    // const Color.fromRGBO(255, 140, 140, 1),
    // const Color.fromRGBO(232, 160, 191, 1),
    // const Color.fromRGBO(233, 102, 160, 1),
    // const Color.fromRGBO(255, 93, 93, 1),
    // const Color.fromRGBO(255, 222, 180, 1),
    // const Color.fromRGBO(253, 247, 195, 1),
    // const Color.fromRGBO(255, 238, 204, 1),
    // const Color.fromRGBO(255, 221, 204, 1),
    // const Color.fromRGBO(255, 204, 204, 1),
    // const Color.fromRGBO(229, 235, 178, 1),
    // const Color.fromRGBO(188, 226, 158, 1),
    // const Color.fromRGBO(205, 233, 144, 1),
    // const Color.fromRGBO(182, 227, 136, 1),
  ];

  final List<Color> pastelPalette = [
    Colors.blue.shade50,
    const Color.fromRGBO(253, 239, 245, 1),
    Colors.amber.shade50,
    Colors.deepPurple.shade50,
    Colors.lightGreen.shade50,
    Colors.pink.shade50,
  ];

  Color getRandomPastel() {
    return pastelPalette.elementAt(Random().nextInt(pastelPalette.length));
  }

  Color getRandomFromPalette({bool withGoodContrast = false}) {
    if (!withGoodContrast) {
      return foregroundPalette
          .elementAt(Random().nextInt(foregroundPalette.length));
    }

    const defaultColor = Colors.deepPurpleAccent;
    const int maxTries = 12;
    int tries = 0;

    Color foundColor = foregroundPalette.elementAt(
      Random().nextInt(foregroundPalette.length),
    );

    while (foundColor.computeLuminance() > 0.4 && (tries < maxTries)) {
      foundColor =
          foregroundPalette[Random().nextInt(foregroundPalette.length)];
      tries++;
    }

    if (foundColor.computeLuminance() > 0.4) {
      return defaultColor;
    }

    return foundColor;
  }

  /// Create a [MaterialColor] from a [Color].
  MaterialColor createMaterialColorFrom(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  List<Topic> topics = [];

  Topic getRandomTopic() {
    return topics.elementAt(Random().nextInt(topics.length));
  }

  /// Fill foreground palette from topics.
  void fillForegroundPalette() {
    for (final Topic topic in topics) {
      foregroundPalette.add(topic.color);
    }
  }

  /// Color for statistics.
  final Color activity = Colors.red;

  final Color clairPink = const Color(0xFFf5eaf9);

  final Color error = Colors.pink.shade200;

  /// Color for books.
  final Color lists = Colors.blue.shade700;

  /// Color for challenges.
  final Color challenges = Colors.amber;

  /// Color for contests.
  final Color inValidation = Colors.indigo;

  final Color dark = const Color(0xFF161616);

  final Color drafts = Colors.orange;

  final Color delete = Colors.pink;

  /// Color for email.
  final Color email = Colors.blue.shade300;

  /// Color for galleries.
  final Color published = Colors.green;

  final Color home = Colors.blue.shade300;

  final Color lightBackground = const Color.fromRGBO(239, 241, 253, 1);
  final Color likes = Colors.pink;
  final Color licenses = Colors.amber.shade800;
  final Color location = Colors.green.shade300;

  final Color password = Colors.orange.shade300;

  /// Primary application's color.
  final Color primary = Colors.deepOrange;
  // final Color primary = Colors.blue.shade700;

  /// Secondary application's color.
  Color secondary = Colors.blue;
  // Color secondary = Colors.pink;

  /// Color for profile.
  final Color profile = Colors.indigo;

  /// Color for projects.
  final Color projects = Colors.amber;

  /// 3th color.
  final Color tertiary = Colors.amber;

  /// Color for review page.
  final Color review = Colors.teal.shade700;

  /// Color for profile page sections.
  final Color sections = Colors.green.shade700;

  /// Color for settings.
  final Color settings = Colors.amber;

  final Color bio = Colors.deepPurple.shade300;

  final Color validation = Colors.green;
}
