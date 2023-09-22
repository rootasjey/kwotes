class Linguistic {
  const Linguistic();

  static const String en = "en";
  static const String fr = "fr";

  static const String english = "English";
  static const String french = "Français";

  List<String> available() {
    return [en, fr];
  }

  String toCode(String? lang) {
    switch (lang) {
      case english:
        return en;
      case french:
        return fr;
      default:
        return en;
    }
  }

  String toFullString(String lang) {
    switch (lang) {
      case en:
        return english;
      case fr:
        return french;
      default:
        return english;
    }
  }
}
