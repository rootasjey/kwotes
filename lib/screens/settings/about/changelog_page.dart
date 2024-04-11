import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:wave_divider/wave_divider.dart";

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: context.beamBack,
              title: "changelog.name".tr(),
              subtitle: "changelog.description".tr(),
            ),
            SliverPadding(
              padding: isMobileSize
                  ? const EdgeInsets.only(
                      top: 0.0,
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
                  widthFactor: isMobileSize ? 0.90 : 0.80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WaveDivider(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          "Last updates",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w200,
                              color: foregroundColor?.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "10/04/2024",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w200,
                              color: foregroundColor?.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Redesign settings page",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Update default profile picture",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Add user avatar on home, search & diary page (to access settings)",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Update search page (font, header, input)",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Add changelog page",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Save last tab selected on \"My Quotes\" page",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: foregroundColor?.withOpacity(0.2),
                        height: 42.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          "Previously",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w200,
                              color: foregroundColor?.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "03/04/2024",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w200,
                              color: foregroundColor?.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Add swipe action on quote items",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Update dashboard card order",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "• Merge drafts, in validation & published pages",
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: foregroundColor?.withOpacity(0.4),
                            ),
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
      ),
    );
  }
}
