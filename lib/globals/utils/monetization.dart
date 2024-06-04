import "dart:io" show Platform;

import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:purchases_flutter/purchases_flutter.dart";

class Monetization {
  const Monetization();

  /// Initialize the platform if it is not already.
  /// Login a new user otherwise.
  Future<void> initOrLogin(String userId) async {
    if (await Purchases.isConfigured) {
      await Purchases.logIn(userId);
      return;
    }

    await initPlatformState(userId);
  }

  /// Initialize the platform state.
  Future<void> initPlatformState(String userId) async {
    if (kIsWeb) {
      return;
    }

    await Purchases.setLogLevel(LogLevel.info);

    String publicApiKey = dotenv.get("RC_PLAY_STORE");
    if (Platform.isAndroid) {
      publicApiKey = dotenv.get("RC_PLAY_STORE");
    } else if (Platform.isIOS || Platform.isMacOS) {
      publicApiKey = dotenv.get("RC_APP_STORE");
    }

    PurchasesConfiguration configuration = PurchasesConfiguration(publicApiKey)
      ..appUserID = userId;

    await Purchases.configure(configuration);
  }

  /// Check if the user has a premium plan.
  Future<bool> hasPremiumPlan() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final Map<String, EntitlementInfo> activeEntitlements =
          customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) return false;
      final bool hasPremium = activeEntitlements.containsKey("premium");

      if (!hasPremium) return false;
      final EntitlementInfo? premiumEntitlement = activeEntitlements["premium"];
      if (premiumEntitlement == null) return false;
      return premiumEntitlement.isActive;
    } catch (error) {
      return false;
    }
  }
}
