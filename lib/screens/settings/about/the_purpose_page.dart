import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class ThePurposePage extends StatelessWidget {
  const ThePurposePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(
            isMobileSize: isMobileSize,
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
        ],
      ),
    );
  }
}
