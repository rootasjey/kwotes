import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/settings/premium/subscriptions_page_body.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:loggy/loggy.dart";
import "package:purchases_flutter/purchases_flutter.dart";

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> with UiLoggy {
  /// Page's state (e.g. idle, loading).
  EnumPageState _pageState = EnumPageState.idle;

  /// Premium entitlement.
  EntitlementInfo _premiumEntitlement = EntitlementInfo.fromJson({});

  @override
  initState() {
    super.initState();
    initProps();
    fetchCustomerInfo();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    // final Color? foregroundColor =
    //     Theme.of(context).textTheme.bodyMedium?.color;

    final UserFirestore userFirestore = context.observe<UserFirestore>(
      EnumSignalId.userFirestore,
    );

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
            SubscriptionsPageBody(
              userPlan: userFirestore.plan,
              pageState: _pageState,
              premiumEntitlement: _premiumEntitlement,
            ),
          ],
        ),
      ),
    );
  }

  void initProps() async {
    Utils.state.refreshPremiumPlan();
  }

  /// Fetch customer info and check if user has premium entitlement.
  void fetchCustomerInfo() async {
    setState(() {
      _pageState = EnumPageState.loading;
    });

    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final Map<String, EntitlementInfo> activeEntitlements =
          customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) return;
      final bool hasPremium = activeEntitlements.containsKey("premium");

      if (!hasPremium) return;
      final EntitlementInfo? premiumEntitlement = activeEntitlements["premium"];
      if (premiumEntitlement == null) return;

      setState(() {
        _pageState = EnumPageState.idle;
        _premiumEntitlement = premiumEntitlement;
      });
    } catch (error) {
      loggy.error(error);
      setState(() {
        _pageState = EnumPageState.idle;
      });
    }
  }
}
