import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/utils/api_keys.dart';
import 'package:figstyle/utils/language.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotifications {
  PushNotifications();

  static Future activate() async {
    await OneSignal.shared.setSubscription(true);
  }

  static Future deactivate() async {
    await OneSignal.shared.setSubscription(false);
  }

  static Future init(BuildContext context) async {
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
    // We recommend removing the following code
    // and instead using an In-App Message to prompt
    // for notification permission.
    final allowed = await OneSignal.shared
            .promptUserForPushNotificationPermission(
                fallbackToSettings: true) ??
        true;

    if (!allowed) {
      return;
    }

    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      final notification = openedResult.notification;
      final quoteId = notification.payload.additionalData['quote']['id'];

      onQuoteTap(context: context, quoteId: quoteId);
    });
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
    await OneSignal.shared.setExternalUserId(id);
  }

  static Future onQuoteTap(
      {@required BuildContext context, @required String quoteId}) {
    if (MediaQuery.of(context).size.width > 600.0) {
      return showFlash(
        context: context,
        persistent: false,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            enableDrag: true,
            margin: const EdgeInsets.only(
              left: 120.0,
              right: 120.0,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            child: FlashBar(
              message: Container(
                height: MediaQuery.of(context).size.height - 100.0,
                padding: const EdgeInsets.all(60.0),
                child: QuotePage(
                  pinnedAppBar: false,
                  quoteId: quoteId,
                ),
              ),
            ),
          );
        },
      );
    }

    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context, scrollController) => QuotePage(
        padding: const EdgeInsets.only(left: 10.0),
        quoteId: quoteId,
        scrollController: scrollController,
      ),
    );
  }

  static Future unlinkAuthUser() async {
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
