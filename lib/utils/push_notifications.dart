import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotifications {
  PushNotifications();

  static Future init() async {
    //Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init("", iOSSettings: {
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

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
      // print(notification.payload.body);
    });
  }

  static Future initDefaultTag() async {
    final tags = await OneSignal.shared.getTags();

    if (tags.isEmpty) {
      await OneSignal.shared.sendTag('quotidian', 'en');
    }
  }
}
