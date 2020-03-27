import 'package:firebase_auth/firebase_auth.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:supercharged/supercharged.dart';

Future<FirebaseUser> getUserAuth() async {
  FirebaseUser userAuth = await tryGetUserAuth();

  if (userAuth == null) {
    userAuth = await Future.delayed(
      2.seconds,
      () async {
        return await tryGetUserAuth();
      }
    );
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
  final credentialsMap = AppLocalStorage.getCredentials();

  final email = credentialsMap['email'];
  final password = credentialsMap['password'];

  if ((email == null || email.isEmpty) || (password == null || password.isEmpty)) {
    return null;
  }

  final auth = await FirebaseAuth.instance
    .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

  return auth.user;
}
