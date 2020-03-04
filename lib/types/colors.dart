import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/types/topic_color.dart';

class ThemeColor extends ChangeNotifier {
  static Color primary = Color(0xFF706FD3);
  static Color secondary = Color(0xFFF56498);
  static Color validation = Color(0xFF02ECC7);
  static Color success = Color(0xFF2ECC71);
  static Color error = Color(0xFFE74C3C);

  Color accent = Color(0xFF706FD3);
  Color background = Colors.black54;
  Color blackOrWhite = Colors.black;

  static List<TopicColor> topicsColors = [];

  bool isColorLoaded = false;

  void initializeBackgroundColor(BuildContext context) {
    final dynamicTheme = DynamicTheme.of(context);
    if (dynamicTheme == null) { return; }

    background = dynamicTheme.brightness == Brightness.dark ?
      Colors.white54 : Colors.black54;

    blackOrWhite = dynamicTheme.brightness == Brightness.dark ?
      Colors.white : Colors.black;
  }

  void updatePalette(BuildContext context, String topic) {
    updateAccent(topic);
    initializeBackgroundColor(context);
  }

  void updateAccent(String topic) {
    final Color color = topicColor(topic);
    accent = color;
    notifyListeners();
  }

  void updateBackground(Brightness brightness) {
    background = brightness == Brightness.dark ?
      Colors.white54 : Colors.black54;

    notifyListeners();
  }

  static Map<int, Color> customSwatchColor(Color color) {
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    Map<int, Color> accentSwatchColor = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return accentSwatchColor;
  }

  static MaterialColor customMaterialColor(Color color) {
    return MaterialColor(color.value, customSwatchColor(color));
  }

  static Color topicColor(String topic) {
    switch (topic) {
      case 'art':
        return Color(0xFF5199FF);
      case 'biology':
        return Color(0xFFCBE724);
      case 'feelings':
        return Color(0xFFFF0000);
      case 'fun':
        return Color(0xFFFFC11E);
      case 'gratitude':
        return Color(0xFFCEFF9D);
      case 'introspection':
        return Color(0xFF0043A4);
      case 'knowledge':
        return Color(0xFFFFDFDC);
      case 'language':
        return Color(0xFFB5FBDD);
      case 'metaphor':
        return Color(0xFF17F1D7);
      case 'motivation':
        return Color(0xFF7AB1FF);
      case 'philosophy':
        return Color(0xFFF375F3);
      case 'poetry':
        return Color(0xFFFF756B);
      case 'proverb':
        return Color(0xFFDF8600);
      case 'psychology':
        return Color(0xFF580BE4);
      case 'retrospection':
        return Color(0xFF2D1457);
      case 'sciences':
        return Color(0xFFE85668);
      case 'sex':
        return Color(0xFFFF2970);
      case 'social':
        return Color(0xFFFEAC92);
      case 'spiritual':
        return Color(0xFFF6DDDF);
      case 'work':
        return Color(0xFF58595B);
      default:
        return primary;
    }
  }

  static void fetchTopicsColors() async {
    final snapshot = await FirestoreApp.instance
      .collection('topics')
      .get();

    if (snapshot.empty) { return; }

    snapshot.forEach((doc) {
      final topicColor = TopicColor.fromJSON(doc.data());
      topicsColors.add(topicColor);
    });
  }
}
