import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
                ? const EdgeInsets.all(24.0)
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
                      "tos.name".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: isMobileSize ? 36.0 : 84.0,
                          fontWeight: FontWeight.w700,
                          color: Constants.colors.getRandomFromPalette(
                            withGoodContrast: true,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text.rich(
                        TextSpan(
                          text: "${"date.last_updated".tr()} : ",
                          children: [
                            TextSpan(
                              text: Jiffy.parseFromDateTime(
                                      Constants.termsOfServiceLastUpdated)
                                  .yMMMMEEEEd,
                            ),
                          ],
                        ),
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: foregroundColor?.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "${"tos.content.0".tr()}\n\n",
                        children: [
                          TextSpan(
                            text: "${"tos.content.1".tr()}\n\n",
                          ),
                          TextSpan(
                            text: "${"tos.content.2".tr()}\n\n",
                          ),
                          TextSpan(
                            text: "${"tos.content.3".tr()}\n\n",
                          ),
                          TextSpan(
                            text: "${"tos.content.4".tr()}\n\n",
                          ),
                          TextSpan(
                            text: "${"tos.content.5".tr()}\n\n",
                          ),
                          TextSpan(
                            text: "${"tos.content.6".tr()}\n\n",
                          ),
                          TextSpan(
                            text: "${"tos.content.7".tr()}\n\n",
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
