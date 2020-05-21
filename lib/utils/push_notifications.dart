import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/router/router.dart';
import 'package:supercharged/supercharged.dart';

class PushNotifications {
  static FirebaseMessaging fcm;
  static StreamSubscription _streamSubscription;
  /// For navigation purposes.
  static BuildContext _context;

  static Color _kKeyUmbraOpacity = Color(0x33000000); // alpha = 0.2
  static Color _kKeyPenumbraOpacity = Color(0x24000000); // alpha = 0.14
  static Color _kAmbientShadowOpacity = Color(0x1F000000); // alpha = 0.12

  static void initialize({String userUid, BuildContext context}) async {
    if (fcm != null) { return; }

    _context = context;
    fcm = FirebaseMessaging();

    if (Platform.isIOS) {
      if (_streamSubscription != null) {
        _streamSubscription.cancel();
      }

      final isOk = await fcm.requestNotificationPermissions(
        IosNotificationSettings()
      );

      if (isOk) { postProcessInit(userUid); }

    } else {
      postProcessInit(userUid);
    }
  }

  static void postProcessInit(String userUid) {
    fcm.configure(
      onLaunch: (Map<String, dynamic> payload) async {
        String path = payload['data'] == null ?
          payload['path'] : payload['data']['path'];

        if (path != null) {
          FluroRouter.router.navigateTo(_context, path);
        }
      },
      onMessage: (Map<String, dynamic> payload) async {
        final payloadBody = payload['notification'] ??
          payload['aps']['alert'];

        if (payloadBody == null) { return; }

        final String title = payloadBody['title'];
        final String body = payloadBody['body'];

        String path = payload['path'];

        if ((payload['data'] == null || payload['data'].length == 0) && path == null) {
          await Flushbar(
            duration: 10.seconds,
            icon: Icon(
              Icons.info,
              color: Colors.white,
            ),
            title: title,
            messageText: Text(
              body,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            boxShadows: <BoxShadow>[
              BoxShadow(offset: Offset(0.0, 3.0), blurRadius: 5.0, spreadRadius: -1.0, color: _kKeyUmbraOpacity),
              BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 10.0, spreadRadius: 0.0, color: _kKeyPenumbraOpacity),
              BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 18.0, spreadRadius: 0.0, color: _kAmbientShadowOpacity),
            ],
          ).show(_context);

          return;
        }

        path = path ?? payload['data']['path'];

        final String message = payload['data'] == null ?
          payload['message'] :
          payload['data']['message'];

        await Flushbar(
          duration: 10.seconds,
          icon: Icon(
            Icons.info,
            color: Colors.white,
          ),
          title: title,
          messageText: Text(
            message,
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          boxShadows: <BoxShadow>[
            BoxShadow(offset: Offset(0.0, 3.0), blurRadius: 5.0, spreadRadius: -1.0, color: _kKeyUmbraOpacity),
            BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 10.0, spreadRadius: 0.0, color: _kKeyPenumbraOpacity),
            BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 18.0, spreadRadius: 0.0, color: _kAmbientShadowOpacity),
          ],
          onTap: path != null ?
            (_) => FluroRouter.router.navigateTo(_context, path) :
            null,
        ).show(_context);
      },
      onResume: (Map<String, dynamic> payload) async {
        String path = payload['data'] == null ?
          payload['path'] :
          payload['data']['path'];

        if (path != null) {
          FluroRouter.router.navigateTo(_context, path);
        }
      },
    );

    if (userUid != null && userUid.length > 0) {
      saveDeviceToken(userUid);
    }
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

  static Future<bool> subMobileQuotidians({String lang}) async {
    try {
      await fcm.subscribeToTopic('quotidians-mobile-$lang');
      return true;

    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  static Future<bool> unsubMobileQuotidians({String lang}) async {
    try {
      await fcm.unsubscribeFromTopic('quotidians-mobile-$lang');
      return true;

    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  static Future<bool> updateQuotidiansSubLang({String lang}) async {
    try {
      // Unsub from all
      ['en', 'fr']
        .forEach((currLang) async {
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
