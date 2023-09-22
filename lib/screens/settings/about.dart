import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

class About extends StatelessWidget {
  const About({
    super.key,
    this.onTapColorPalette,
  });

  /// Callback fired when "Color palette" button is tapped.
  final void Function()? onTapColorPalette;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 48.0,
        right: 72.0,
        bottom: 120.0,
      ),
      sliver: SliverList.list(children: [
        Text.rich(
          TextSpan(
            text: "${"about.name".tr()}: ",
            children: [
              WidgetSpan(
                child: Icon(
                  UniconsLine.heart,
                  color: Constants.colors.getRandomFromPalette(),
                  size: 82.0,
                ),
                style: const TextStyle(
                  height: 1.0,
                ),
              ),
            ],
          ),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 72.0,
              fontWeight: FontWeight.w100,
              color: foregroundColor?.withOpacity(0.6),
            ),
          ),
        )
            .animate(delay: 350.ms)
            .fadeIn(duration: 150.ms)
            .slideY(begin: 0.8, end: 0.0, duration: 150.ms),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ActionChip(
              onPressed: onTapColorPalette,
              label: Text("color.palette".tr()),
            )
          ]
              .animate(delay: 300.ms, interval: 50.ms)
              .fadeIn(duration: 150.ms)
              .slideY(begin: 0.8, end: 0.0),
        )
      ]),
    );
  }
}
