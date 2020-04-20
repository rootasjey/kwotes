import 'package:firebase_auth/firebase_auth.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:mobx/mobx.dart';

part 'user_state.g.dart';

class UserState = UserStateBase with _$UserState;

abstract class UserStateBase with Store {
  FirebaseUser _userAuth;

  @observable
  String lang = 'en';

  @observable
  bool isUserConnected = false;

  /// Last time the favourites has been updated.
  @observable
  DateTime updatedFavAt = DateTime.now();

  Future<FirebaseUser> get userAuth async {
    if (_userAuth != null) {
      return _userAuth;
    }

    _userAuth = await FirebaseAuth.instance.currentUser();

    if (_userAuth == null) {
      await _signin();
    }

    return _userAuth;
  }

  @action
  void setLang(String newLang) {
    lang = newLang;
  }

  @action
  void setUserConnected() {
    isUserConnected = true;
  }

  @action
  void setUserDisconnected() {
    isUserConnected = true;
  }

  /// Signin user with credentials if FirebaseAuth is null.
  Future _signin() async {
    final credentialsMap = appLocalStorage.getCredentials();

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

    _userAuth = auth.user;
    isUserConnected = true;
  }

  @action
  void updateFavDate() {
    updatedFavAt = DateTime.now();
  }
}

final userState = UserState();
