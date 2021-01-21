// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StateUser on StateUserBase, Store {
  final _$avatarUrlAtom = Atom(name: 'StateUserBase.avatarUrl');

  @override
  String get avatarUrl {
    _$avatarUrlAtom.reportRead();
    return super.avatarUrl;
  }

  @override
  set avatarUrl(String value) {
    _$avatarUrlAtom.reportWrite(value, super.avatarUrl, () {
      super.avatarUrl = value;
    });
  }

  final _$canManageQuotesAtom = Atom(name: 'StateUserBase.canManageQuotes');

  @override
  bool get canManageQuotes {
    _$canManageQuotesAtom.reportRead();
    return super.canManageQuotes;
  }

  @override
  set canManageQuotes(bool value) {
    _$canManageQuotesAtom.reportWrite(value, super.canManageQuotes, () {
      super.canManageQuotes = value;
    });
  }

  final _$langAtom = Atom(name: 'StateUserBase.lang');

  @override
  String get lang {
    _$langAtom.reportRead();
    return super.lang;
  }

  @override
  set lang(String value) {
    _$langAtom.reportWrite(value, super.lang, () {
      super.lang = value;
    });
  }

  final _$isFirstLaunchAtom = Atom(name: 'StateUserBase.isFirstLaunch');

  @override
  bool get isFirstLaunch {
    _$isFirstLaunchAtom.reportRead();
    return super.isFirstLaunch;
  }

  @override
  set isFirstLaunch(bool value) {
    _$isFirstLaunchAtom.reportWrite(value, super.isFirstLaunch, () {
      super.isFirstLaunch = value;
    });
  }

  final _$isUserConnectedAtom = Atom(name: 'StateUserBase.isUserConnected');

  @override
  bool get isUserConnected {
    _$isUserConnectedAtom.reportRead();
    return super.isUserConnected;
  }

  @override
  set isUserConnected(bool value) {
    _$isUserConnectedAtom.reportWrite(value, super.isUserConnected, () {
      super.isUserConnected = value;
    });
  }

  final _$usernameAtom = Atom(name: 'StateUserBase.username');

  @override
  String get username {
    _$usernameAtom.reportRead();
    return super.username;
  }

  @override
  set username(String value) {
    _$usernameAtom.reportWrite(value, super.username, () {
      super.username = value;
    });
  }

  final _$updatedFavAtAtom = Atom(name: 'StateUserBase.updatedFavAt');

  @override
  DateTime get updatedFavAt {
    _$updatedFavAtAtom.reportRead();
    return super.updatedFavAt;
  }

  @override
  set updatedFavAt(DateTime value) {
    _$updatedFavAtAtom.reportWrite(value, super.updatedFavAt, () {
      super.updatedFavAt = value;
    });
  }

  final _$signOutAsyncAction = AsyncAction('StateUserBase.signOut');

  @override
  Future<dynamic> signOut(
      {BuildContext context, bool redirectOnComplete = false}) {
    return _$signOutAsyncAction.run(() => super
        .signOut(context: context, redirectOnComplete: redirectOnComplete));
  }

  final _$StateUserBaseActionController =
      ActionController(name: 'StateUserBase');

  @override
  void setAvatarUrl(String url) {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setAvatarUrl');
    try {
      return super.setAvatarUrl(url);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFirstLaunch(bool value) {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setFirstLaunch');
    try {
      return super.setFirstLaunch(value);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLang(String newLang) {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setLang');
    try {
      return super.setLang(newLang);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserConnected() {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setUserConnected');
    try {
      return super.setUserConnected();
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserDisconnected() {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setUserDisconnected');
    try {
      return super.setUserDisconnected();
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserName(String name) {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setUserName');
    try {
      return super.setUserName(name);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAdminValue(bool value) {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.setAdminValue');
    try {
      return super.setAdminValue(value);
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateFavDate() {
    final _$actionInfo = _$StateUserBaseActionController.startAction(
        name: 'StateUserBase.updateFavDate');
    try {
      return super.updateFavDate();
    } finally {
      _$StateUserBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
avatarUrl: ${avatarUrl},
canManageQuotes: ${canManageQuotes},
lang: ${lang},
isFirstLaunch: ${isFirstLaunch},
isUserConnected: ${isUserConnected},
username: ${username},
updatedFavAt: ${updatedFavAt}
    ''';
  }
}
