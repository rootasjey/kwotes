
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'user_state.g.dart';

class UserState = UserStateBase with _$UserState;

abstract class UserStateBase with Store {
  @observable
  FirebaseUser _userAuth;

  @observable
  String lang = 'en';

  @observable
  bool isUserConnected = false;

  /// Last time the favourites has been updated.
  @observable
  DateTime updatedFavAt = DateTime.now();

  @computed
  Future<FirebaseUser> get userAuth async {
    if (_userAuth != null) {
      return _userAuth;
    }

    await setAuth();
    return _userAuth;
  }

  @action
  Future setAuth() async {
    _userAuth = await FirebaseAuth.instance.currentUser();
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

  @action
  void updateFavDate() {
    updatedFavAt = DateTime.now();
  }
}

final userState = UserState();
