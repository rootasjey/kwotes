import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final EdgeInsets padding = isMobileSize
        ? const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0)
        : const EdgeInsets.only(top: 12.0, left: 48.0, right: 72.0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsPageHeader(
            isMobileSize: isMobileSize,
            onTapBackButton: context.beamBack,
            title: "language.name".tr(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: padding,
              child: Text(
                "quote.language.change_app_quotes".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    color: foregroundColor?.withOpacity(0.6),
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                  Utils.linguistic.available().map(
                (EnumLanguageSelection data) {
                  final bool selected = currentLocale == data.name;
                  return ListTile(
                    selected: selected,
                    onTap: () {
                      context.setLocale(Locale(data.name));
                    },
                    title: Text(Utils.linguistic.toFullString(data.name)),
                    subtitleTextStyle: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 10.0,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                    dense: true,
                    trailing: selected
                        ? const Icon(
                            TablerIcons.check,
                            size: 18.0,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                },
              ).toList()),
            ),
          ),
        ],
      ),
    );
  }
}
