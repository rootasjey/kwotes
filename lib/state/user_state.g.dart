// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserState on UserStateBase, Store {
  final _$langAtom = Atom(name: 'UserStateBase.lang');

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

  final _$isUserConnectedAtom = Atom(name: 'UserStateBase.isUserConnected');

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

  final _$updatedFavAtAtom = Atom(name: 'UserStateBase.updatedFavAt');

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

  final _$UserStateBaseActionController =
      ActionController(name: 'UserStateBase');

  @override
  void setLang(String newLang) {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setLang(newLang);
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserConnected() {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setUserConnected();
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserDisconnected() {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setUserDisconnected();
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateFavDate() {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.updateFavDate();
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'lang: ${lang.toString()},isUserConnected: ${isUserConnected.toString()},updatedFavAt: ${updatedFavAt.toString()}';
    return '{$string}';
  }
}
