import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/utils.dart";

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    super.key,
    this.isMobileSize = false,
    this.show = true,
    this.onScrollToTop,
    this.onTapBackButton,
    this.onTapCloseIcon,
    this.title = "",
    this.subtitle = "",
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// If true, the page app bar will be shown.
  final bool show;

  /// Callback fired when the user scrolls to the top of the page.
  final void Function()? onScrollToTop;

  /// Callback fired when the user taps the back button on the page app bar.
  final void Function()? onTapBackButton;

  /// Callback fired when the user taps the close icon on the page app bar.
  final void Function()? onTapCloseIcon;

  /// Page title.
  final String title;

  /// Page subtitle.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return PageAppBar(
      elevation: 0.0,
      hideBackButton: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isMobileSize: isMobileSize,
      toolbarHeight: isMobileSize ? 82.0 : 100.0,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: onScrollToTop,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Hero(
                      tag: "settings",
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: isMobileSize ? 18.0 : 24.0,
                              fontWeight: FontWeight.w500,
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
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onTapBackButton != null)
              Positioned(
                top: 0.0,
                left: 8.0,
                child: CircleButton(
                  onTap: onTapBackButton,
                  radius: 12.0,
                  tooltip: "back".tr(),
                  icon: const Icon(TablerIcons.arrow_left, size: 14.0),
                  margin: const EdgeInsets.only(left: 0.0),
                ),
              ),
            if (onTapCloseIcon != null)
              Positioned(
                top: 0.0,
                right: 8.0,
                child: CircleButton(
                  onTap: onTapCloseIcon,
                  radius: 12.0,
                  tooltip: "close".tr(),
                  icon: const Icon(TablerIcons.x, size: 14.0),
                  margin: const EdgeInsets.only(right: 0.0),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
