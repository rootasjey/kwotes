import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  static FirebaseMessaging fcm;

  static Future initialize() async {
    fcm = FirebaseMessaging();

    if (Platform.isIOS) {
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    fcm.configure(
      onBackgroundMessage: backgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );

    saveDeviceToken();
  }

  static Future<dynamic> backgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  static void saveDeviceToken() async {
    final fcmToken = await fcm.getToken();
    print(fcmToken);
    if (fcmToken == null) { return; }

    // final tokenRef = db
    //   .collection('user')
  }
}
