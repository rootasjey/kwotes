import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/user.dart';

void checkConnectedOrNavSignin({BuildContext context}) async {
  try {
    final userAuth = stateUser.userAuth;

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
