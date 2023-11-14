import "package:kwotes/globals/constants/color_palette.dart";
import "package:kwotes/globals/constants/links.dart";
import "package:kwotes/globals/constants/storage_keys.dart";

class Constants {
  /// App name.
  static const appName = "kwotes";

  /// App version.
  static const appVersion = "3.0.0";

  /// App build number.
  static const appBuildNumber = 15;

  /// Last time terms of service was updated.
  static final DateTime termsOfServiceLastUpdated = DateTime(2020, 12, 12);

  static const domainUrl = "https://kwotes.fr";
  static const authorUrl = "$domainUrl/authors";
  static const quoteUrl = "$domainUrl/quotes";
  static const referenceUrl = "$domainUrl/references";
  static const githubUrl = "https://github.com/rootasjey/kwotes";

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

  /// App external links.
  static const links = Links();

  /// Unique keys to store and retrieve data from local storage.
  static const storageKeys = StorageKeys();
}
