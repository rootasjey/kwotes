// import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotifications extends StatefulWidget {
  @override
  _PushNotificationsState createState() => _PushNotificationsState();
}

class _PushNotificationsState extends State<PushNotifications> {
  final FirebaseMessaging fcm = FirebaseMessaging();
  // final Firestore db = Firestore.instance;
  // StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );

    saveDeviceToken();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }

  void saveDeviceToken() async {
    final fcmToken = await fcm.getToken();
    print(fcmToken);
    if (fcmToken == null) { return; }

    // final tokenRef = db
    //   .collection('user')
  }
}
