import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SettingsPageHeader(
              isMobileSize: isMobileSize,
              onTapBackButton: () => Navigator.of(context).pop(),
              onTapCloseIcon: () async {
                NavigationStateHelper.navigateBackToLastRoot(context);
              },
              title: "premium.subscription.name".tr(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                ),
                child: Text(
                  "premium.subscription.description".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor?.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  bottom: 12.0,
                ),
                child: Card(
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            TablerIcons.hourglass,
                            size: 24.0,
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "premium.comming_soon.name".tr(),
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    color: foregroundColor?.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              Text(
                                "premium.comming_soon.description".tr(),
                                style: Utils.calligraphy.body(
                                  textStyle: TextStyle(
                                    color: foregroundColor?.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
