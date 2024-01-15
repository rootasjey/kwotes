import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/color_palette/card_color_palette.dart";
import "package:kwotes/types/topic.dart";
import "package:super_context_menu/super_context_menu.dart";

class ColorPalettePageBody extends StatelessWidget {
  const ColorPalettePageBody({
    super.key,
    required this.windowSize,
    this.onTapColorCard,
    this.onLongPressColorCard,
    this.onCopyHex,
    this.onCopyRGBA,
    this.onCopyValue,
    this.isMobileSize = false,
  });

  /// Adapt user interface to small screens.
  final bool isMobileSize;

  /// Callback fired when color card is tapped.
  final void Function(Topic topic)? onTapColorCard;

  /// Callback fired when color card is long pressed.
  final void Function(Topic topic)? onLongPressColorCard;

  /// Callback fired to copy color's hex value.
  final void Function(Topic topic)? onCopyHex;

  /// Callback fired to copy color's RGBA value.
  final void Function(Topic topic)? onCopyRGBA;

  /// Callback fired to copy color's 32-bit value.
  final void Function(Topic topic)? onCopyValue;

  /// Window size.
  final Size windowSize;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: isMobileSize
            ? const EdgeInsets.only(
                top: 24.0,
                left: 12.0,
                right: 12.0,
              )
            : const EdgeInsets.only(
                bottom: 72.0,
                left: 76.0,
                right: 76.0,
                top: 54.0,
              ),
        child: FractionallySizedBox(
          widthFactor: windowSize.width < 1100.0 ? 1.0 : 0.4,
          child: Column(
            children: [
              ActionChip(
                onPressed: context.beamBack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(TablerIcons.arrow_left),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("back".tr()),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Text(
                  "color.palette".tr(),
                  style: Utils.calligraphy.body3(
                    textStyle: TextStyle(
                      fontSize: isMobileSize ? 32 : 64.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().slideY(begin: 0.8, end: 0.0).fadeIn(),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: Constants.colors.topics
                    .map((Topic topic) {
                      return ContextMenuWidget(
                        child: CardColorPalette(
                          topic: topic,
                          name: topic.name,
                          onTap: onTapColorCard,
                          onLongPress: onLongPressColorCard,
                        ),
                        menuProvider: (MenuRequest menuRequest) {
                          return Menu(children: [
                            MenuAction(
                              title: "color.copy.hex".tr(),
                              callback: () => onCopyHex?.call(topic),
                            ),
                            MenuAction(
                              title: "color.copy.rgba".tr(),
                              callback: () => onCopyRGBA?.call(topic),
                            ),
                            MenuAction(
                              title: "color.copy.value".tr(),
                              callback: () => onCopyValue?.call(topic),
                            ),
                          ]);
                        },
                      );
                    })
                    .toList()
                    .animate(delay: 100.ms, interval: 25.ms)
                    .slideY(begin: 0.8, end: 0.0)
                    .fadeIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
