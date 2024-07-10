import "dart:ui";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:bottom_sheet/bottom_sheet.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:purchases_ui_flutter/purchases_ui_flutter.dart";

class PremiumDialogPage extends StatefulWidget {
  const PremiumDialogPage({super.key});

  @override
  State<PremiumDialogPage> createState() => _PremiumDialogPageState();
}

class _PremiumDialogPageState extends State<PremiumDialogPage> with UiLoggy {
  @override
  void initState() {
    super.initState();
    presentPaywallIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: const SizedBox.shrink(),
      ),
    );
  }

  void openDialog() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      NavigationStateHelper.rootContext = context;
      showFlexibleBottomSheet(
        context: context,
        minHeight: 0.0,
        initHeight: 0.6,
        maxHeight: 0.9,
        anchors: [0.0, 0.9],
        bottomSheetBorderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        builder: (
          BuildContext context,
          scrollController,
          bottomSheetOffset,
        ) {
          NavigationStateHelper.bottomSheetScrollController = scrollController;
          final Color? foregroundColor =
              Theme.of(context).textTheme.bodyMedium?.color;

          return PopScope(
            onPopInvoked: (bool didPop) async {
              if (!context.mounted) return;

              final int tabIndex = await Utils.vault.getHomePageTabIndex();
              String routeTab = "/h";
              switch (tabIndex) {
                case 0:
                  routeTab = "/h";
                  break;
                case 1:
                  routeTab = "/s";
                  break;
                case 2:
                  routeTab = "/d";
                  break;
                default:
                  routeTab = "/h";
              }

              if (!context.mounted) return;
              Beamer.of(context, root: true).beamToNamed(routeTab);
            },
            child: Theme(
              data: AdaptiveTheme.of(context).theme,
              child: BasicShortcuts(
                onCancel: context.beamBack,
                child: SafeArea(
                  child: Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        TablerIcons.crown,
                                        size: 42.0,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "premium.name".tr(),
                                        style: Utils.calligraphy.body(
                                          textStyle: const TextStyle(
                                            fontSize: 42.0,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 36.0),
                                  child: Text(
                                    "premium.description".tr(),
                                    style: Utils.calligraphy.body(
                                      textStyle: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            foregroundColor?.withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  elevation: 2.0,
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    side: BorderSide(
                                      color: Constants.colors.premium,
                                    ),
                                  ),
                                  child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "premium.subscription.name".tr(),
                                            style: Utils.calligraphy.body(
                                              textStyle: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "premium.subscription.subtitle"
                                                .tr(),
                                            style: Utils.calligraphy.body(
                                              textStyle: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w400,
                                                color: foregroundColor
                                                    ?.withOpacity(0.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  elevation: 2.0,
                                  margin: const EdgeInsets.only(top: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    side: BorderSide(
                                      color: Constants.colors.primary,
                                    ),
                                  ),
                                  child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "premium.in_app_purchase.name".tr(),
                                            style: Utils.calligraphy.body(
                                              textStyle: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "premium.in_app_purchase.subtitle"
                                                .tr(),
                                            style: Utils.calligraphy.body(
                                              textStyle: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w400,
                                                color: foregroundColor
                                                    ?.withOpacity(0.6),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void presentPaywallIfNeeded() async {
    final UserFirestore userFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore).value;

    if (userFirestore.id.isEmpty) {
      context.get<Signal<String>>(EnumSignalId.navigationBarPath).updateValue(
          (prevValue) => "${DashboardLocation.route}-${DateTime.now()}");
      return;
    }

    if (!Utils.graphic.isMobile()) {
      Future.delayed(1.seconds, () {
        context.beamBack();
        Utils.graphic.showSnackbar(
          context,
          message: "Paywall only available on mobile",
        );
      });
      return;
    }

    final PaywallResult paywallResult =
        await RevenueCatUI.presentPaywallIfNeeded("premium");

    if (!context.mounted) return;
    final BuildContext savedContext = context;

    if (paywallResult == PaywallResult.purchased ||
        paywallResult == PaywallResult.restored) {
      final Signal<UserFirestore> signalFirestoreUser =
          savedContext.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

      if (signalFirestoreUser.value.id.isNotEmpty) {
        signalFirestoreUser.updateValue(
          (UserFirestore user) => user.copyWith(
            plan: EnumUserPlan.premium,
          ),
        );
      }
    }

    savedContext.beamBack();
  }
}
