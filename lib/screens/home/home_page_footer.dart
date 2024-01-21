import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/brightness_button.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/components/buttons/language_selector.dart";
import "package:kwotes/components/buttons/like_button_vanilla.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class HomePageFooter extends StatelessWidget {
  const HomePageFooter({
    super.key,
    this.isMobileSize = false,
    this.iconColor,
    this.margin = EdgeInsets.zero,
    this.onChangeLanguage,
    this.onTapGitHub,
    this.onTapLikeButton,
    this.foregroundColor,
  });

  /// Adapt user interface to small screens.
  final bool isMobileSize;

  /// Text foreground color.
  final Color? foregroundColor;

  /// Icon color.
  final Color? iconColor;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when language is changed.
  final void Function(EnumLanguageSelection locale)? onChangeLanguage;

  /// Callback fired to open GitHub url project.
  final void Function()? onTapGitHub;

  /// Callback fired when like button is tapped.
  final void Function()? onTapLikeButton;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets textPadding = EdgeInsets.only(left: 16.0);

    return SliverPadding(
      padding: margin,
      sliver: SliverList.list(
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LikeButtonVanilla(
                tooltip: "footer.give_some_love".tr(),
                onPressed: onTapLikeButton,
                size: const Size(62.0, 62.0),
              ),
              const BrightnessButton(),
            ],
          ),
          Padding(
            padding: textPadding,
            child: Text(
              "footer.thanks".tr(args: [Constants.appName]),
              style: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Padding(
            padding: textPadding.add(const EdgeInsets.only(bottom: 24.0)),
            child: Text(
              "footer.tagline".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoredTextButton(
                textValue: "footer.github".tr(),
                onPressed: onTapGitHub,
                iconOnRight: true,
                textFlex: 0,
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(TablerIcons.arrow_right, size: 18.0),
                ),
                margin: EdgeInsets.only(left: textPadding.left / 2),
              ),
            ],
          ),
          Padding(
            // padding: EdgeInsets.zero,
            padding: textPadding.add(const EdgeInsets.only(bottom: 24.0)),
            child: Text(
              "footer.made_in".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: foregroundColor?.withOpacity(0.4),
                ),
              ),
            ),
          ),
          const Divider(thickness: 1.0),
          LanguageSelector(
            margin: EdgeInsets.only(left: textPadding.left),
            onChangeLanguage: onChangeLanguage,
          ),
          const Divider(thickness: 1.0),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    TablerIcons.versions,
                    size: 20.0,
                    color: foregroundColor?.withOpacity(0.6),
                  ),
                ),
                Text(
                  "${"version".tr()} ${Constants.appVersion}",
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor?.withOpacity(0.6),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 54.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppIcon(
                  size: 24.0,
                  margin: EdgeInsets.only(right: 6.0),
                ),
                Text(
                  Constants.appName,
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor?.withOpacity(0.6),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "footer.rights".tr(args: ["© 2019 - ${DateTime.now().year}"]),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor?.withOpacity(0.6),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
