import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/about/credit_item_data.dart";
import "package:url_launcher/url_launcher_string.dart";

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? color = Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: true,
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: isMobileSize
                  ? const EdgeInsets.only(
                      top: 24.0,
                      left: 24.0,
                      right: 24.0,
                      bottom: 200.0,
                    )
                  : const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 48.0,
                    ),
              sliver: SliverToBoxAdapter(
                child: FractionallySizedBox(
                  widthFactor: isMobileSize ? 1.0 : 0.80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Utils.passage.deepBack(context),
                        icon: const Icon(TablerIcons.arrow_left),
                        style: IconButton.styleFrom(
                          backgroundColor: accentColor.withOpacity(0.1),
                        ),
                      ),
                      Text(
                        "credits.name".tr(),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 84.0,
                            fontWeight: FontWeight.w700,
                            color: Constants.colors.getRandomFromPalette(
                              onlyDarkerColors: true,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "credits.description".tr(),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            color: color?.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Text(
                          "credits.general_purpose.name".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w400,
                              color: color?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "credits.general_purpose.description".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: color?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: getGeneralPurposeItems()
                            .map((CreditItemData data) => toTile(color, data))
                            .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Text(
                          "credits.libraries.name".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w400,
                              color: color?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "credits.libraries.description".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: color?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: getPackageItems()
                            .map((CreditItemData data) => toTile(color, data))
                            .toList(),
                      ),
                      ColoredTextButton(
                        textFlex: 0,
                        textValue: "back".tr(),
                        onPressed: () => Utils.passage.deepBack(context),
                        icon: const Icon(TablerIcons.arrow_narrow_left),
                        margin: const EdgeInsets.only(
                          top: 42.0,
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: accentColor.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Return a list of general purpose items.
  List<CreditItemData> getGeneralPurposeItems() {
    return [
      CreditItemData(
        title: "Flutter",
        subtitle: "Frontend UI library.",
        link: "https://flutter.dev",
        iconData: TablerIcons.brand_flutter,
      ),
      CreditItemData(
        title: "Dart",
        subtitle: "Programming language.",
        link: "https://dart.dev",
        iconData: TablerIcons.code,
      ),
      CreditItemData(
        title: "GitHub",
        subtitle: "Source code repository.",
        link: "https://github.com",
        iconData: TablerIcons.brand_github,
      ),
      CreditItemData(
        title: "VSCode",
        subtitle: "Code editor.",
        link: "https://code.visualstudio.com",
        iconData: TablerIcons.braces,
      ),
      CreditItemData(
        title: "Firebase",
        subtitle: "Cloud database & services.",
        link: "https://firebase.google.com",
        iconData: TablerIcons.brand_firebase,
      ),
      CreditItemData(
        title: "Codium",
        subtitle: "AI code assistant.",
        link: "https://vscodium.com",
        iconData: TablerIcons.robot,
      ),
    ];
  }

  /// Return a list of package items.
  List<CreditItemData> getPackageItems() {
    return [
      CreditItemData(
        title: "adaptive_theme",
        subtitle: "Theme manager.",
        link: "https://pub.dev/packages/adaptive_theme",
      ),
      CreditItemData(
        title: "algolia",
        subtitle: "Search service.",
        link: "https://pub.dev/packages/algolia",
      ),
      CreditItemData(
        title: "animated_text_kit",
        subtitle: "Text animation.",
        link: "https://pub.dev/packages/animated_text_kit",
      ),
      CreditItemData(
        title: "beamer",
        subtitle: "A litte less complex router (than the native one).",
        link: "https://pub.dev/packages/beamer",
      ),
      CreditItemData(
        title: "bottom_sheet",
        subtitle: "Custom bottom sheet widget that can be resized "
            "in response to drag gestures and then scrolled.",
        link: "https://pub.dev/packages/bottom_sheet",
      ),
      CreditItemData(
        title: "boxy",
        subtitle: "Additional & flexible layout widgets.",
        link: "https://pub.dev/packages/boxy",
      ),
      CreditItemData(
        title: "cupertino_icons",
        subtitle: "Icons from Apple.",
        link: "https://pub.dev/packages/cupertino_icons",
      ),
      CreditItemData(
        title: "cloud_firestore",
        subtitle: "Firestore database to access & store quote data.",
        link: "https://pub.dev/packages/cloud_firestore",
      ),
      CreditItemData(
        title: "cloud_functions",
        subtitle: "Cloud functions for server-side code.",
        link: "https://pub.dev/packages/cloud_functions",
      ),
      CreditItemData(
        title: "dismissible_page",
        subtitle: "Widget page implementing swipe-to-dismiss gesture.",
        link: "https://pub.dev/packages/dismissible_page",
      ),
      CreditItemData(
        title: "easy_localization",
        subtitle: "Internationalization for Flutter applications.",
        link: "https://pub.dev/packages/easy_localization",
      ),
      CreditItemData(
        title: "file_picker",
        subtitle: "File picker for selecting folder to save quote images.",
        link: "https://pub.dev/packages/file_picker",
      ),
      CreditItemData(
        title: "firebase_auth",
        subtitle: "Firebase authentication for signing in users.",
        link: "https://pub.dev/packages/firebase_auth",
      ),
      CreditItemData(
        title: "firebase_analytics",
        subtitle: "Firebase analytics for tracking app usage.",
        link: "https://pub.dev/packages/firebase_analytics",
      ),
      CreditItemData(
        title: "firebase_core",
        subtitle: "Firebase core for initializing Firebase services.",
        link: "https://pub.dev/packages/firebase_core",
      ),
      CreditItemData(
        title: "firebase_storage",
        subtitle: "Firebase storage for accessing static images.",
        link: "https://pub.dev/packages/firebase_storage",
      ),
      CreditItemData(
        title: "flex_list",
        subtitle: "Puts as many provided elements as possible "
            "in one row (like Wrap), but also extends "
            "the width of the elements by the remaining space per row.",
        link: "https://pub.dev/packages/firebase_storage",
      ),
      CreditItemData(
        title: "flutter_animate",
        subtitle: "A performant library "
            "that makes it simple to add almost any kind "
            "of animated effect in Flutter.",
        link: "https://pub.dev/packages/flutter_animate",
      ),
      CreditItemData(
        title: "flutter_dotenv",
        subtitle: "Load configuration at runtime from a .env file "
            "which can be used throughout the application.",
        link: "https://pub.dev/packages/flutter_dotenv",
      ),
      CreditItemData(
        title: "flutter_improved_scrolling",
        subtitle:
            "An attempt to implement better scrolling for Flutter Web and Desktop."
            "Includes keyboard, MButton and custom mouse wheel scrolling.",
        link: "https://pub.dev/packages/flutter_improved_scrolling",
      ),
      CreditItemData(
        title: "flutter_langdetect",
        subtitle: "A Flutter package for language detection, "
            "ported from the Python langdetect library.",
        link: "https://pub.dev/packages/flutter_langdetect",
      ),
      CreditItemData(
        title: "flutter_launcher_icons",
        subtitle: "A command-line tool which simplifies "
            "the task of updating your Flutter app's launcher icon.",
        link: "https://pub.dev/packages/flutter_launcher_icons",
      ),
      CreditItemData(
        title: "flutter_loggy",
        subtitle: "Loggy extention for Flutter."
            "Loggy is an highly customizable logger for dart "
            "that uses mixins to show all the needed info.",
        link: "https://pub.dev/packages/flutter_loggy",
      ),
      CreditItemData(
        title: "flutter_solidart",
        subtitle: "A simple state-management library inspired by SolidJS.",
        link: "https://pub.dev/packages/flutter_solidart",
      ),
      CreditItemData(
        title: "flutter_tabler_icons",
        subtitle: "Tabler icons for Flutter.",
        link: "https://pub.dev/packages/flutter_tabler_icons",
      ),
      CreditItemData(
        title: "glutton",
        subtitle: "Simple multiplatform local data storage.",
        link: "https://pub.dev/packages/glutton",
      ),
      CreditItemData(
        title: "google_fonts",
        subtitle: "Google fonts for Flutter.",
        link: "https://pub.dev/packages/google_fonts",
      ),
      CreditItemData(
        title: "image_downloader_web",
        subtitle: "Simply download images on web. "
            "Web implementation of image_downloader.",
        link: "https://pub.dev/packages/image_downloader_web",
      ),
      CreditItemData(
        title: "infinite_carousel",
        subtitle: "Carousel widget that supports infinite looping "
            "and gives precise control over selected item anchor "
            "and carousel scroll velocity.",
        link: "https://pub.dev/packages/infinite_carousel",
      ),
      CreditItemData(
        title: "jiffy",
        subtitle: "Display relative date & time. Date parser & formatter.",
        link: "https://pub.dev/packages/jiffy",
      ),
      CreditItemData(
        title: "just_the_tooltip",
        subtitle: "Customizable tooltip.",
        link: "https://pub.dev/packages/just_the_tooltip",
      ),
      CreditItemData(
        title: "liquid_pull_to_refresh",
        subtitle: "A beautiful and custom refresh indicator for flutter.",
        link: "https://pub.dev/packages/liquid_pull_to_refresh",
      ),
      CreditItemData(
        title: "loggy",
        subtitle:
            "Highly customizable logger for dart that uses mixins to show all the needed info.",
        link: "https://pub.dev/packages/loggy",
      ),
      CreditItemData(
        title: "lottie",
        subtitle: "Lottie is a mobile library for Android and iOS "
            "that parses Adobe After Effects animations exported as json "
            "with Bodymovin and renders them natively on mobile!"
            "This repository is an unofficial conversion of the Lottie-android "
            "library in pure Dart.",
        link: "https://pub.dev/packages/lottie",
      ),
      CreditItemData(
        title: "photo_view",
        subtitle: "A simple zoomable image/content widget for Flutter.",
        link: "https://pub.dev/packages/photo_view",
      ),
      CreditItemData(
        title: "rive",
        subtitle: "Real-time interactive design and animation tool.",
        link: "https://pub.dev/packages/rive",
      ),
      CreditItemData(
        title: "salomon_bottom_bar",
        subtitle: "A beautiful bottom navigation bar.",
        link: "https://pub.dev/packages/salomon_bottom_bar",
      ),
      CreditItemData(
        title: "screenshot",
        subtitle: "Capture widgets as images. "
            "Even if there're not rendered on screen.",
        link: "https://pub.dev/packages/screenshot",
      ),
      CreditItemData(
        title: "share_plus",
        subtitle: "A Flutter plugin to share content from your Flutter app "
            "via the platform's share dialog.",
        link: "https://pub.dev/packages/share_plus",
      ),
      CreditItemData(
        title: "smooth_page_indicator",
        subtitle: "Customizable animated page indicator "
            "with a set of built-in effects.",
        link: "https://pub.dev/packages/smooth_page_indicator",
      ),
      CreditItemData(
        title: "super_context_menu",
        subtitle: "Single context menu widget that works accross "
            "all desktop platforms, mobile platforms and web.",
        link: "https://pub.dev/packages/super_context_menu",
      ),
      CreditItemData(
        title: "text_wrap_auto_size",
        subtitle: "Wraps text and auto sizes it with respect "
            "to the given dimensions, including style, "
            "text properties and correct hyphenation."
            "Result can be accessed programmatically.",
        link: "https://pub.dev/packages/text_wrap_auto_size",
      ),
      CreditItemData(
        title: "url_launcher",
        subtitle: "Open URL in browser.",
        link: "https://pub.dev/packages/url_launcher",
      ),
      CreditItemData(
        title: "verbal_expressions",
        subtitle: "Regular expressions made easy.",
        link: "https://pub.dev/packages/verbal_expressions",
      ),
      CreditItemData(
        title: "window_manager",
        subtitle: "Allows Flutter desktop apps "
            "to resizing and repositioning the window.",
        link: "https://pub.dev/packages/window_manager",
      ),
    ];
  }

  /// Build credit item tile.
  Widget toTile(Color? color, CreditItemData data) {
    return ListTile(
      title: Text(data.title),
      subtitle: Text(data.subtitle),
      leading: data.iconData != null ? Icon(data.iconData) : null,
      onTap: () => launchUrlString(data.link),
      titleTextStyle: Utils.calligraphy.body(
        textStyle: TextStyle(
          color: color?.withOpacity(0.8),
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
        ),
      ),
      subtitleTextStyle: Utils.calligraphy.body(
        textStyle: TextStyle(
          color: color?.withOpacity(0.6),
        ),
      ),
    );
  }
}
