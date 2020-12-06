import 'package:figstyle/utils/api_keys.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:figstyle/utils/storage_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotifications {
  PushNotifications();

  static Future activate() async {
    await OneSignal.shared.setSubscription(true);
  }

  static Future deactivate() async {
    await OneSignal.shared.setSubscription(false);
  }

  static Future init() async {
    if (kIsWeb) {
      return;
    }

    // Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init(ONESIGNAL_APPID, iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false,
    });

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    // The promptForPushNotificationsWithUserResponse function will show
    // the iOS push notification prompt.
    // We recommend removing the following code and instead using
    // an In-App Message to prompt for notification permission.
    final allowed = await OneSignal.shared
            .promptUserForPushNotificationPermission(
                fallbackToSettings: true) ??
        true; // android automatically allow notifications

    if (!allowed) {
      return;
    }

    initDefaultTag();

    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      final notification = openedResult.notification;
      final additionalData = notification.payload.additionalData;

      if (additionalData != null && additionalData['quoteid'] != null) {
        handleQuotidian(notification);
        return;
      }

      handleOtherNotifications();
    });
  }

  static void handleOtherNotifications() async {
    appStorage.setString(
        StorageKeys.onOpenNotificationPath, 'notifications_center');
  }

  static void handleQuotidian(
    OSNotification notification,
  ) async {
    final quoteId = notification.payload.additionalData['quoteid'];
    appStorage.setString(StorageKeys.onOpenNotificationPath, 'quote_page');
    appStorage.setString(StorageKeys.quoteIdNotification, quoteId);
  }

  static Future initDefaultTag() async {
    final tags = await OneSignal.shared.getTags();

    if (tags.isEmpty) {
      await OneSignal.shared.sendTag('quotidian', 'en');
    }
  }

  static Future<bool> isActive() async {
    final state = await OneSignal.shared.getPermissionSubscriptionState();
    return state.subscriptionStatus.subscribed;
  }

  static Future linkAuthUser(String id) async {
    if (kIsWeb) {
      return;
    }

    await OneSignal.shared.setExternalUserId(id);
  }

  static Future unlinkAuthUser() async {
    if (kIsWeb) {
      return;
    }

    await OneSignal.shared.removeExternalUserId();
  }

  static void updateLangNotification(String lang) {
    if (!Language.available().contains(lang)) {
      debugPrint("The language specified is not a valid one.");
      return;
    }

    OneSignal.shared.sendTag('quotidian', lang);
  }
}
