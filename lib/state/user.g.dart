// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StateUser on StateUserBase, Store {
  final _$avatarUrlAtom = Atom(name: 'StateUserBase.avatarUrl');

  @override
  String get avatarUrl {
    _$avatarUrlAtom.context.enforceReadPolicy(_$avatarUrlAtom);
    _$avatarUrlAtom.reportObserved();
    return super.avatarUrl;
  }

  @override
  set avatarUrl(String value) {
    _$avatarUrlAtom.context.conditionallyRunInAction(() {
      super.avatarUrl = value;
      _$avatarUrlAtom.reportChanged();
    }, _$avatarUrlAtom, name: '${_$avatarUrlAtom.name}_set');
  }

  final _$langAtom = Atom(name: 'StateUserBase.lang');

  @override
  String get lang {
    _$langAtom.context.enforceReadPolicy(_$langAtom);
    _$langAtom.reportObserved();
    return super.lang;
  }

  @override
  set lang(String value) {
    _$langAtom.context.conditionallyRunInAction(() {
      super.lang = value;
      _$langAtom.reportChanged();
    }, _$langAtom, name: '${_$langAtom.name}_set');
  }

  final _$isFirstLaunchAtom = Atom(name: 'StateUserBase.isFirstLaunch');

  @override
  bool get isFirstLaunch {
    _$isFirstLaunchAtom.context.enforceReadPolicy(_$isFirstLaunchAtom);
    _$isFirstLaunchAtom.reportObserved();
    return super.isFirstLaunch;
  }

  @override
  set isFirstLaunch(bool value) {
    _$isFirstLaunchAtom.context.conditionallyRunInAction(() {
      super.isFirstLaunch = value;
      _$isFirstLaunchAtom.reportChanged();
    }, _$isFirstLaunchAtom, name: '${_$isFirstLaunchAtom.name}_set');
  }

  final _$isUserConnectedAtom = Atom(name: 'StateUserBase.isUserConnected');

  @override
  bool get isUserConnected {
    _$isUserConnectedAtom.context.enforceReadPolicy(_$isUserConnectedAtom);
    _$isUserConnectedAtom.reportObserved();
    return super.isUserConnected;
  }

  @override
  set isUserConnected(bool value) {
    _$isUserConnectedAtom.context.conditionallyRunInAction(() {
      super.isUserConnected = value;
      _$isUserConnectedAtom.reportChanged();
    }, _$isUserConnectedAtom, name: '${_$isUserConnectedAtom.name}_set');
  }

  final _$usernameAtom = Atom(name: 'StateUserBase.username');

  @override
  String get username {
    _$usernameAtom.context.enforceReadPolicy(_$usernameAtom);
    _$usernameAtom.reportObserved();
    return super.username;
  }

  @override
  set username(String value) {
    _$usernameAtom.context.conditionallyRunInAction(() {
      super.username = value;
      _$usernameAtom.reportChanged();
    }, _$usernameAtom, name: '${_$usernameAtom.name}_set');
  }

  final _$updatedFavAtAtom = Atom(name: 'StateUserBase.updatedFavAt');

  @override
  DateTime get updatedFavAt {
    _$updatedFavAtAtom.context.enforceReadPolicy(_$updatedFavAtAtom);
    _$updatedFavAtAtom.reportObserved();
    return super.updatedFavAt;
  }

  @override
  set updatedFavAt(DateTime value) {
    _$updatedFavAtAtom.context.conditionallyRunInAction(() {
      super.updatedFavAt = value;
      _$updatedFavAtAtom.reportChanged();
    }, _$updatedFavAtAtom, name: '${_$updatedFavAtAtom.name}_set');
  }

  final _$signOutAsyncAction = AsyncAction('signOut');

  @override
  Future<dynamic> signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  final _$StateUserBaseActionController =
      ActionController(name: 'StateUserBase');

  @override
  void setAvatarUrl(String url) {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.setAvatarUrl(url);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFirstLaunch(bool value) {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.setFirstLaunch(value);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLang(String newLang) {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.setLang(newLang);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserConnected() {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.setUserConnected();
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserDisconnected() {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.setUserDisconnected();
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserName(String name) {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.setUserName(name);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateFavDate() {
    final _$actionInfo = _$StateUserBaseActionController.startAction();
    try {
      return super.updateFavDate();
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'avatarUrl: ${avatarUrl.toString()},lang: ${lang.toString()},isFirstLaunch: ${isFirstLaunch.toString()},isUserConnected: ${isUserConnected.toString()},username: ${username.toString()},updatedFavAt: ${updatedFavAt.toString()}';
    return '{$string}';
  }
}
