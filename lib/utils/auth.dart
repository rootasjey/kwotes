import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:supercharged/supercharged.dart';

import '../screens/signin.dart';

void checkAuth({BuildContext context}) async {
  try {
    final userAuth = await userState.userAuth;

    if (userAuth == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));
      return;
    }
  } catch (error) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Signin()));
  }
}

Future<FirebaseUser> getUserAuth() async {
  FirebaseUser userAuth = await tryGetUserAuth();

  if (userAuth == null) {
    userAuth = await Future.delayed(2.seconds, () async {
      return await tryGetUserAuth();
    });
  }

  return userAuth;
}

Future<FirebaseUser> tryGetUserAuth() async {
  FirebaseUser userAuth;

  userAuth = await FirebaseAuth.instance.currentUser();

  if (userAuth != null) {
    return userAuth;
  }

  // 2nd try
  final credentialsMap = appLocalStorage.getCredentials();

  final email = credentialsMap['email'];
  final password = credentialsMap['password'];

  if ((email == null || email.isEmpty) ||
      (password == null || password.isEmpty)) {
    return null;
  }

  final auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  return auth.user;
}
