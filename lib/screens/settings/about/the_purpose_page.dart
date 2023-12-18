import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class ThePurposePage extends StatelessWidget {
  const ThePurposePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color accentColor = Constants.colors.getRandomFromPalette(
      withGoodContrast: true,
    );

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: IconButton(
                    onPressed: () => Utils.passage.deepBack(context),
                    icon: const Icon(
                      TablerIcons.arrow_left,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                    Text(
                      "purpose.name".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 84.0,
                          fontWeight: FontWeight.w700,
                          color: Constants.colors.getRandomFromPalette(
                            withGoodContrast: true,
                          ),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "purpose.content.0".tr(),
                        children: [
                          TextSpan(
                            text: " ${"purpose.content.1".tr()}",
                          ),
                          TextSpan(
                            text: " ${"purpose.content.2".tr()}",
                          ),
                          TextSpan(
                            text: " ${"purpose.content.3".tr()}.",
                            style: TextStyle(
                              color: Constants.colors.getRandomFromPalette(
                                withGoodContrast: true,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: "\n\n${"purpose.content.4".tr()}",
                          ),
                          TextSpan(
                            text: "purpose.content.5".tr(),
                          ),
                          TextSpan(
                            text: "purpose.content.6".tr(),
                          ),
                          TextSpan(
                            text: "\n\n${"purpose.content.7".tr()}",
                          ),
                          TextSpan(
                            text: " ${"purpose.content.8".tr()}",
                          ),
                        ],
                      ),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                          color: foregroundColor?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ColoredTextButton(
                textFlex: 0,
                textValue: "back".tr(),
                onPressed: () => Utils.passage.deepBack(context),
                icon: const Icon(TablerIcons.arrow_narrow_left),
                margin: const EdgeInsets.only(
                  left: 12.0,
                  bottom: 64.0,
                  right: 12.0,
                ),
                padding: const EdgeInsets.only(
                  right: 12.0,
                ),
                style: TextButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
