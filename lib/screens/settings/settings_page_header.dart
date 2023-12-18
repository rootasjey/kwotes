import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    super.key,
    this.isMobileSize = false,
    this.onScrollToTop,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Callback fired when the user scrolls to the top of the page.
  final void Function()? onScrollToTop;

  @override
  Widget build(BuildContext context) {
    return PageAppBar(
      isMobileSize: isMobileSize,
      children: [
        Padding(
          padding: isMobileSize
              ? const EdgeInsets.only(left: 6.0, bottom: 24.0)
              : const EdgeInsets.only(left: 6.0, bottom: 42.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onScrollToTop,
                child: Hero(
                  tag: "settings",
                  child: Material(
                    color: Colors.transparent,
                    child: Text.rich(
                      TextSpan(text: "settings.name".tr(), children: [
                        TextSpan(
                          text: ".",
                          style: TextStyle(
                            color: Constants.colors.settings,
                          ),
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Utils.calligraphy.title(
                        textStyle: TextStyle(
                          fontSize: 74.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
