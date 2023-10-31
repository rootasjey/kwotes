import "package:kwotes/types/enums/enum_language_selection.dart";

class Linguistic {
  const Linguistic();

  /// English language code.
  static const String en = "en";

  /// French language code.
  static const String fr = "fr";

  /// English full length language.
  static const String english = "English";

  /// French full length language.
  static const String french = "Français";

  /// List of available languages in the app.
  List<EnumLanguageSelection> available() {
    return [
      EnumLanguageSelection.en,
      EnumLanguageSelection.fr,
    ];
  }

  // List<String> available() {
  //   return [en, fr];
  // }

  /// Return 2-characters string from full language string.
  String toCode(String? fullLanguage) {
    switch (fullLanguage) {
      case english:
        return en;
      case french:
        return fr;
      default:
        return en;
    }
  }

  /// Return the full language name from a 2-characters string.
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
