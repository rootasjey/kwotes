import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";
import "package:purchases_flutter/models/entitlement_info_wrapper.dart";

class SubscriptionsPageBody extends StatelessWidget {
  const SubscriptionsPageBody({
    super.key,
    required this.premiumEntitlement,
    this.userPlan = EnumUserPlan.free,
    this.pageState = EnumPageState.idle,
  });

  /// Page's state (e.g. idle, loading).
  final EnumPageState pageState;

  /// Current ser plan.
  final EnumUserPlan userPlan;

  /// Premium entitlement.
  /// Non-null if user has it.
  final EntitlementInfo premiumEntitlement;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "premium.subscription.loading".tr(),
      );
    }

    if (userPlan == EnumUserPlan.free) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              Text(
                "premium.subscription.free".tr(),
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ),
        child: ListView(
          children: [
            Text(premiumEntitlement.expirationDate ?? ""),
          ],
        ),
      ),
    );
  }
}
