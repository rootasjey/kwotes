import 'package:cloud_functions/cloud_functions.dart';
import 'package:figstyle/types/create_account_resp.dart';
import 'package:figstyle/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Network interface for user's actions.
class UsersActions {
  /// Check email availability accross the app.
  static Future<bool> checkEmailAvailability(String email) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable('users-checkEmailAvailability');

      final resp = await callable.call({'email': email});
      final isOk = resp.data['isAvailable'] as bool;
      return isOk;
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      appLogger.e(error);
      return false;
    }
  }

  /// Create a new account.
  static Future<CreateAccountResp> createAccount({
    @required String email,
    @required String username,
    @required String password,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable('users-createAccount');

      final response = await callable.call({
        'username': username,
        'password': password,
        'email': email,
      });

      return CreateAccountResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e("[code: ${exception.code}] - ${exception.message}");
      return CreateAccountResp.fromException(exception);
    } catch (error) {
      return CreateAccountResp.fromMessage(error.toString());
    }
  }

  /// Check email format.
  static bool checkEmailFormat(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
        .hasMatch(email);
  }

  /// Check username availability.
  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable('users-checkUsernameAvailability');

      final resp = await callable.call({'name': username});
      final isOk = resp.data['isAvailable'] as bool;
      return isOk;
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      appLogger.e(error);
      return false;
    }
  }

  /// Check username format.
  /// Must contains 3 or more alpha-numerical characters.
  static bool checkUsernameFormat(String username) {
    final str = RegExp("[a-zA-Z0-9_]{3,}").stringMatch(username);
    return username == str;
  }
}
