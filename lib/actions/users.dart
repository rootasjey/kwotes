import 'package:cloud_functions/cloud_functions.dart';
import 'package:figstyle/types/cloud_func_error.dart';
import 'package:figstyle/types/create_account_resp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<bool> checkEmailAvailability(String email) async {
  try {
    final callable = CloudFunctions(
      app: Firebase.app(),
      region: 'europe-west3',
    ).getHttpsCallable(
      functionName: 'users-checkEmailAvailability',
    );

    final resp = await callable.call({'email': email});
    final isOk = resp.data['isAvailable'] as bool;
    return isOk;
  } on CloudFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return false;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<CreateAccountResp> createAccount({
  @required String email,
  @required String username,
  @required String password,
}) async {
  try {
    final callable = CloudFunctions(
      app: Firebase.app(),
      region: 'europe-west3',
    ).getHttpsCallable(
      functionName: 'users-createAccount',
    );

    final response = await callable.call({
      'username': username,
      'password': password,
      'email': email,
    });

    return CreateAccountResp.fromJSON(response.data);
  } on CloudFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return CreateAccountResp(
      success: false,
      error: CloudFuncError(
        code: exception.code,
        message: exception.message,
      ),
    );
  } catch (error) {
    return CreateAccountResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

bool checkEmailFormat(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
      .hasMatch(email);
}

Future<bool> checkUsernameAvailability(String username) async {
  try {
    final callable = CloudFunctions(
      app: Firebase.app(),
      region: 'europe-west3',
    ).getHttpsCallable(
      functionName: 'users-checkUsernameAvailability',
    );

    final resp = await callable.call({'name': username});
    final isOk = resp.data['isAvailable'] as bool;
    return isOk;
  } on CloudFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return false;
  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

bool checkUsernameFormat(String username) {
  final str = RegExp("[a-zA-Z0-9_]{3,}").stringMatch(username);
  return username == str;
}
