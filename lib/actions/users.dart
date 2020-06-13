
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

bool checkEmailFormat(String email) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
    .hasMatch(email);
}

Future<bool> checkEmailAvailability(String email) async {
  try {
    final callable = CloudFunctions(
      app: FirebaseApp.instance,
      region: 'europe-west3',
    ).getHttpsCallable(
      functionName: 'users-checkEmailAvailability',
    );

    final resp = await callable.call({'email': email});
    final isOk = resp.data['isAvailable'] as bool;
    return isOk;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}

Future<bool> checkNameAvailability(String username) async {
  try {
    final callable = CloudFunctions(
      app: FirebaseApp.instance,
      region: 'europe-west3',
    ).getHttpsCallable(
      functionName: 'users-checkNameAvailability',
    );

    final resp = await callable.call({'name': username});
    final isOk = resp.data['isAvailable'] as bool;
    return isOk;

  } catch (error) {
    debugPrint(error.toString());
    return false;
  }
}
