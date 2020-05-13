import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  static FirebaseMessaging fcm;
  static StreamSubscription _streamSubscription;

  static void initialize({String userUid}) async {
    fcm = FirebaseMessaging();

    if (Platform.isIOS) {
      if (_streamSubscription != null) {
        _streamSubscription.cancel();
      }

      _streamSubscription = fcm.onIosSettingsRegistered
      .listen((event) {
        postProcessInit(userUid);
      });

      fcm.requestNotificationPermissions(IosNotificationSettings());

    } else {
      postProcessInit(userUid);
    }
  }

  static void postProcessInit(String userUid) {
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

    saveDeviceToken(userUid);
  }

  static Future backgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      // final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      // final dynamic notification = message['notification'];
    }

    // Or do other work.
    return null;
  }

  static void saveDeviceToken(String userUid) async {
    final fcmToken = await fcm.getToken();
    if (fcmToken == null) { return; }

    final tokenRef = await Firestore.instance
      .collection('users')
      .document(userUid)
      .collection('tokens')
      .document(fcmToken)
      .get();

    if (tokenRef.exists) { return; }

    await tokenRef.reference.setData({
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
