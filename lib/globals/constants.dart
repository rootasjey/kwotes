import "package:kwotes/globals/constants/color_palette.dart";
import "package:kwotes/globals/constants/links.dart";
import "package:kwotes/globals/constants/storage_keys.dart";

class Constants {
  /// App name.
  static const appName = "kwotes";

  /// App version.
  static const appVersion = "1.0.0";

  /// App build number.
  static const appBuildNumber = 1;

  static const domainUrl = "https://kwotes.fr";
  static const authorUrl = "$domainUrl/authors";
  static const quoteUrl = "$domainUrl/quotes";
  static const referenceUrl = "$domainUrl/references";

  /// Allowed image file extension for illustrations.
  static const List<String> allowedImageExt = [
    "jpg",
    "jpeg",
    "png",
    "webp",
    "tiff",
  ];

  /// All necessary colors for the app.
  static final colors = ColorPalette();

  static List<String> letters = [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
  ];

  /// App external links.
  static const links = Links();

  /// Unique keys to store and retrieve data from local storage.
  static const storageKeys = StorageKeys();
}
