import "package:kwotes/globals/utils.dart";
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

  /// Current language.
  static String currentLanguage = "en";

  /// Initialize the current language.
  Future<void> initCurrentLanguage() async {
    currentLanguage = await getLanguage();
  }

  /// List of available languages in the app.
  List<EnumLanguageSelection> available() {
    return [
      EnumLanguageSelection.en,
      EnumLanguageSelection.fr,
    ];
  }

  /// Get the current language.
  Future<String> getLanguage() async {
    final EnumLanguageSelection savedLanguage = await Utils.vault.getLanguage();
    if (available().contains(savedLanguage)) {
      return savedLanguage.name;
    }

    return "en";
  }

  /// Return the current language as enum [EnumLanguageSelection].
  EnumLanguageSelection getLanguageSelection() {
    switch (currentLanguage) {
      case "en":
        return EnumLanguageSelection.en;
      case "fr":
        return EnumLanguageSelection.fr;
      default:
        return EnumLanguageSelection.en;
    }
  }

  EnumLanguageSelection getLanguageFromString(String language) {
    switch (language) {
      case "en":
        return EnumLanguageSelection.en;
      case "fr":
        return EnumLanguageSelection.fr;
      default:
        return EnumLanguageSelection.en;
    }
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
