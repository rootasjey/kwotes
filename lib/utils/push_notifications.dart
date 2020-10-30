import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/router/rerouter.dart';
import 'package:figstyle/utils/app_localstorage.dart';

class PushNotifications {
  static FirebaseMessaging fcm;
  static StreamSubscription _streamSubscription;

  /// For navigation purposes.
  static BuildContext _context;

  static void initialize({
    String userUid,
    BuildContext context,
  }) async {
    if (fcm != null) {
      return;
    }

    _context = context;
    fcm = FirebaseMessaging();

    if (Platform.isIOS) {
      if (_streamSubscription != null) {
        _streamSubscription.cancel();
      }

      final isOk =
          await fcm.requestNotificationPermissions(IosNotificationSettings());

      if (isOk) {
        postProcessInit(userUid: userUid);
      }
    } else {
      postProcessInit(userUid: userUid);
    }
  }

  static void postProcessInit({String userUid}) {
    fcm.configure(
      onLaunch: (Map<String, dynamic> payload) async {
        String path =
            payload['data'] == null ? payload['path'] : payload['data']['path'];

        if (path != null) {
          Rerouter.push(context: _context, value: path);
        }
      },
      onMessage: (Map<String, dynamic> payload) async {
        final payloadBody = payload['notification'] ?? payload['aps']['alert'];

        if (payloadBody == null) {
          return;
        }

        final String title = payloadBody['title'];
        final String body = payloadBody['body'];

        String path = payload['path'];

        if ((payload['data'] == null || payload['data'].length == 0) &&
            path == null) {
          showSnack(
            context: _context,
            message: "$title: $body",
            type: SnackType.info,
          );

          return;
        }

        path = path ?? payload['data']['path'];

        final String message = payload['data'] == null
            ? payload['message']
            : payload['data']['message'];

        showSnack(
          context: _context,
          message: "$title: $message",
          type: SnackType.info,
        );
      },
      onResume: (Map<String, dynamic> payload) async {
        String path =
            payload['data'] == null ? payload['path'] : payload['data']['path'];

        if (path != null) {
          Rerouter.push(context: _context, value: path);
        }
      },
    );

    if (userUid != null && userUid.length > 0) {
      saveDeviceToken(userUid);
    }

    bool isDeviceSubNotif = appLocalStorage.isDeviceSubNotifActive();
    bool isQuotidianNotifActive = appLocalStorage.isQuotidianNotifActive();

    if (!isDeviceSubNotif && isQuotidianNotifActive) {
      subMobileQuotidians();
    }
  }

  static Future saveDeviceToken(String userUid) async {
    if (userUid == null || userUid.isEmpty) {
      return;
    }

    final fcmToken = await fcm.getToken();
    if (fcmToken == null) {
      return;
    }

    try {
      final tokenRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('tokens')
          .doc(fcmToken)
          .get();

      if (tokenRef.exists) {
        return;
      }

      await tokenRef.reference.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      appLocalStorage.clearUserAuthData();
    }
  }

  static Future<bool> subMobileQuotidians({String lang}) async {
    try {
      await fcm.subscribeToTopic('quotidians-mobile-$lang');
      appLocalStorage.setDeviceSubNotif(true);
      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  static Future<bool> unsubMobileQuotidians({String lang}) async {
    try {
      await fcm.unsubscribeFromTopic('quotidians-mobile-$lang');
      appLocalStorage.setDeviceSubNotif(false);
      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  static Future<bool> updateQuotidiansSubLang({String lang}) async {
    try {
      // Unsub from all
      ['en', 'fr'].forEach((currLang) async {
        await fcm.unsubscribeFromTopic('quotidians-mobile-$currLang');
      });

      await fcm.subscribeToTopic('quotidians-mobile-$lang');
      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
