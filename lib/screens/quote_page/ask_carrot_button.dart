import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:glowy_borders/glowy_borders.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class AskCarrotButton extends StatelessWidget {
  const AskCarrotButton({
    super.key,
    this.onTap,
  });

  /// Callback fired when user taps on this button.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SizedBox(
      height: 44.0,
      // height: 50.0,
      child: AnimatedGradientBorder(
        borderSize: 1.0,
        glowSize: 1.0,
        animationProgress: null,
        animationTime: 4,
        borderRadius: BorderRadius.circular(12.0),
        gradientColors: [
          Constants.colors.foregroundPalette[7],
          Constants.colors.foregroundPalette[8],
          Constants.colors.foregroundPalette[2],
          Constants.colors.foregroundPalette[3],
          Constants.colors.foregroundPalette[4],
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0.0,
            vertical: 0.0,
          ),
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: foregroundColor,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              textStyle: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(
                  width: 0.8,
                  color: Colors.transparent,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcon(
                  size: 20.0,
                  onTap: onTap,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                  ),
                  child: AnimatedTextKit(
                    onTap: onTap,
                    repeatForever: true,
                    isRepeatingAnimation: true,
                    pause: const Duration(seconds: 4),
                    animatedTexts: [
                      ColorizeAnimatedText(
                        "carrot.ask_carrot".tr(),
                        textStyle: Utils.calligraphy.code(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 14.0,
                          ),
                        ),
                        colors: [
                          foregroundColor ?? Colors.black,
                          Constants.colors.foregroundPalette[0],
                          Constants.colors.foregroundPalette[1],
                          Constants.colors.foregroundPalette[2],
                          Constants.colors.foregroundPalette[3],
                          Constants.colors.foregroundPalette[4],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(TablerIcons.chevron_right, size: 14.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
