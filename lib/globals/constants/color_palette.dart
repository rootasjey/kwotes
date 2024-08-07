import "dart:math";

import "package:flutter/material.dart";
import "package:kwotes/types/enums/enum_frame_border_style.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/topic.dart";

class ColorPalette {
  /// All necessary colors for the app.
  ColorPalette();

  /// List of foreground colors based on topics.
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

  /// List of darker foreground colors based on topics.
  final List<Color> darkerForegroundPalette = [];

  final List<Color> pastelPalette = [
    Colors.blue.shade50,
    const Color.fromRGBO(253, 239, 245, 1),
    Colors.amber.shade50,
    Colors.deepPurple.shade50,
    Colors.lightGreen.shade50,
    Colors.pink.shade50,
  ];

  /// Returns the color of the search category.
  Color getSearchColor(EnumSearchCategory categorySelected) {
    switch (categorySelected) {
      case EnumSearchCategory.quotes:
        return Colors.pink;
      case EnumSearchCategory.authors:
        return Colors.amber;
      case EnumSearchCategory.references:
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }

  /// Returns a random color from the pastel palette.
  Color getRandomPastel() {
    return pastelPalette.elementAt(Random().nextInt(pastelPalette.length));
  }

  /// Returns a random color from the foreground palette.
  Color getRandomFromPalette({bool onlyDarkerColors = false}) {
    final Color defaultColor = secondary;

    if (onlyDarkerColors) {
      return darkerForegroundPalette.isNotEmpty
          ? darkerForegroundPalette
              .elementAt(Random().nextInt(darkerForegroundPalette.length))
          : defaultColor;
    }

    return foregroundPalette.elementAt(
      Random().nextInt(foregroundPalette.length),
    );
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

  /// Returns topic color from topic name.
  Color getColorFromTopicName(
    BuildContext context, {
    required String topicName,
  }) {
    if (topicName.isEmpty) {
      return Colors.indigo.shade200;
    }

    final Topic topic = topics.firstWhere(
      (Topic x) => x.name == topicName,
      orElse: () => Topic.empty(),
    );

    if (topic.name.isEmpty) {
      return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return topic.color;
  }

  /// Returns a random topic.
  Topic getRandomTopic() {
    return topics.elementAt(Random().nextInt(topics.length));
  }

  Color lastBorderColor = Colors.blue;

  /// Return border color from style.
  Color getBorderColorFromStyle(
      BuildContext context, EnumFrameBorderStyle style) {
    switch (style) {
      case EnumFrameBorderStyle.colored:
        return lastBorderColor;
      case EnumFrameBorderStyle.discrete:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : const Color.fromRGBO(241, 237, 255, 1.0);
      case EnumFrameBorderStyle.highContrast:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
      default:
        return const Color.fromRGBO(241, 237, 255, 1.0);
    }
  }

  /// Fill foreground palette from topics.
  void fillForegroundPalette() {
    for (final Topic topic in topics) {
      foregroundPalette.add(topic.color);
    }
  }

  /// Fill foreground palette with darker colors from topics.
  void fillDarkerPalette() {
    for (final Topic topic in topics) {
      if (topic.color.computeLuminance() < 0.5) {
        darkerForegroundPalette.add(topic.color);
      }
    }
  }

  /// Opacity for start swipe actions.
  final double swipeStartOpacity = 0.4;

  /// Color for statistics.
  final Color activity = Colors.red;

  final Color clairPink = const Color(0xFFf5eaf9);
  final Color references = Colors.green.shade300;
  final Color topicColor = Colors.deepPurple.shade300;

  final Color error = Colors.pink.shade200;

  /// Color for books.
  final Color lists = Colors.blue.shade700;

  /// Color for challenges.
  final Color quotes = Colors.amber.shade300;

  /// Color for contests.
  final Color inValidation = const Color(0xFF002875);

  final Color dark = const Color(0xFF161616);

  final Color drafts = Colors.orange;

  final Color delete = Colors.pink;

  /// Color for email.
  final Color email = Colors.blue.shade300;

  /// Color for galleries.
  final Color published = Colors.green;
  final Color save = Colors.lightGreen;
  final Color edit = Colors.amber;

  final Color home = Colors.blue.shade300;

  final Color authors = Colors.blue.shade300;
  final Color characters = Colors.indigo.shade400;

  final Color lightBackground = const Color.fromRGBO(239, 241, 253, 1);
  final Color likes = Colors.pink;
  final Color licenses = Colors.amber.shade800;
  final Color location = Colors.green.shade300;

  final Color password = Colors.orange.shade300;

  final Color premium = Colors.amber.shade700;

  /// Primary application's color.
  final Color primary = Colors.deepPurple.shade400;
  // final Color primary = Colors.blue.shade700;

  /// Secondary application's color.
  Color secondary = Colors.blue;

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

  final Color search = Colors.deepPurple.shade300;

  final Color validation = Colors.green;
}
