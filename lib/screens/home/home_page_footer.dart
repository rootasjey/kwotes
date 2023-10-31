import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/screens/home/home_text_button.dart";
import "package:kwotes/types/user/user_firestore.dart";

class HomePageFooter extends StatelessWidget {
  const HomePageFooter({
    super.key,
    required this.userFirestoreSignal,
    this.isMobileSize = false,
    this.iconColor,
    this.onAddQuote,
    this.onFetchRandomQuotes,
    this.onTapGitHub,
    this.onTapOpenRandomQuote,
    this.onTapSettings,
  });

  /// Adapt user interface to small screens.
  final bool isMobileSize;

  /// Icon color.
  final Color? iconColor;

  /// Callback fired to add a new quote.
  final void Function()? onAddQuote;

  /// Callback fired to fetch new random quotes.
  final void Function()? onFetchRandomQuotes;

  /// Callback fired to open GitHub url project.
  final void Function()? onTapGitHub;

  /// Callback fired to open a random quote.
  final void Function()? onTapOpenRandomQuote;

  /// Callback fired to open settings.
  final void Function()? onTapSettings;

  /// Signal containing data about the current authenticated user.
  final Signal<UserFirestore> userFirestoreSignal;

  @override
  Widget build(BuildContext context) {
    final Widget openRandomButton = HomeTextButton(
      icon: const Icon(TablerIcons.hand_finger),
      iconOnly: isMobileSize,
      onPressed: onTapOpenRandomQuote,
      textValue: "quote.open_random".tr(),
      tooltip: isMobileSize ? "quote.open_random".tr() : "",
    );

    final Widget shuffleButton = HomeTextButton(
      icon: const Icon(TablerIcons.arrows_shuffle),
      iconOnly: isMobileSize,
      margin: isMobileSize ? EdgeInsets.zero : const EdgeInsets.only(top: 6.0),
      onPressed: onFetchRandomQuotes,
      textValue: "quote.shuffle".tr(),
      tooltip: isMobileSize ? "quote.shuffle".tr() : "",
    );

    final Widget addQuoteButton = HomeTextButton(
      icon: const Icon(TablerIcons.plus),
      iconOnly: isMobileSize,
      margin: isMobileSize ? EdgeInsets.zero : const EdgeInsets.only(top: 6.0),
      onPressed: onAddQuote,
      textValue: "quote.add.a".tr(),
      tooltip: isMobileSize ? "quote.add.a".tr() : "",
    );

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 48.0,
        right: 48.0,
        top: 24.0,
        bottom: 120.0,
      ),
      sliver: SliverList.list(
        children: [
          if (!isMobileSize) ...[
            Align(
              alignment: Alignment.topLeft,
              child: openRandomButton,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: shuffleButton,
            ),
            SignalBuilder(
              signal: userFirestoreSignal,
              builder: (
                BuildContext context,
                UserFirestore userFirestore,
                Widget? child,
              ) {
                if (!userFirestore.rights.canProposeQuote) {
                  return Container();
                }

                return Align(
                  alignment: Alignment.topLeft,
                  child: addQuoteButton,
                );
              },
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 16.0,
              children: [
                if (isMobileSize) ...[
                  openRandomButton,
                  shuffleButton,
                  SignalBuilder(
                    signal: userFirestoreSignal,
                    builder: (
                      BuildContext context,
                      UserFirestore userFirestore,
                      Widget? child,
                    ) {
                      if (!userFirestore.rights.canProposeQuote) {
                        return const SizedBox.shrink();
                      }

                      return addQuoteButton;
                    },
                  ),
                ],
                HomeTextButton(
                  icon: const Icon(TablerIcons.settings),
                  iconOnly: true,
                  onPressed: onTapSettings,
                  textValue: "settings.name".tr(),
                  tooltip: "settings.name".tr(),
                ),
                HomeTextButton(
                  icon: const Icon(TablerIcons.brand_github),
                  iconOnly: true,
                  onPressed: onTapGitHub,
                  textValue: "GitHub",
                  tooltip: "GitHub",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
