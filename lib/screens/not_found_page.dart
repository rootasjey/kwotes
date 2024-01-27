import "dart:math";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class NotFoundPage extends StatelessWidget {
  /// 404 page.
  const NotFoundPage({super.key});

  static const List<String> _imagePaths = [
    "assets/images/malanga.png",
    "assets/images/sweet-potatoes.png",
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int randomImageInt = Random().nextInt(_imagePaths.length);
    final int randomQuoteInt = Random().nextInt(5);
    final Color? foregroundTextColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(42.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Stack(
                    children: [
                      Container(
                        foregroundDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            Constants.colors.getRandomPastel(),
                            Constants.colors.getRandomPastel(),
                            Constants.colors.getRandomPastel(),
                            Constants.colors.getRandomPastel(),
                          ]),
                        ),
                      ),
                      Image.asset(
                        // "assets/images/malanga.png",
                        _imagePaths[randomImageInt],
                        width: 200.0,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    "404",
                    style: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        fontSize: 84.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600.0),
                    child: Text(
                      "not_found.quotes.$randomQuoteInt".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 42.0,
                          fontWeight: FontWeight.w300,
                          color: foregroundTextColor?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                ColoredTextButton(
                  textValue: "back".tr(),
                  textFlex: 0,
                  style: TextButton.styleFrom(
                    foregroundColor: foregroundTextColor,
                    backgroundColor: isDark
                        ? Constants.colors.getRandomFromPalette(
                            onlyDarkerColors: true,
                          )
                        : Constants.colors.getRandomPastel(),
                  ),
                  padding: const EdgeInsets.only(right: 8.0),
                  margin: const EdgeInsets.only(top: 32.0),
                  accentColor: Colors.amber.shade200,
                  icon: const Icon(TablerIcons.arrow_left, size: 18.0),
                  onPressed: () {
                    if (context.canBeamBack) {
                      context.beamBack();
                      return;
                    }

                    context.beamToNamed("/");
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
