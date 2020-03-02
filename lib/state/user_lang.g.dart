// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_lang.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserLang on UserLangBase, Store {
  final _$currentAtom = Atom(name: 'UserLangBase.current');

  @override
  String get current {
    _$currentAtom.context.enforceReadPolicy(_$currentAtom);
    _$currentAtom.reportObserved();
    return super.current;
  }

  @override
  set current(String value) {
    _$currentAtom.context.conditionallyRunInAction(() {
      super.current = value;
      _$currentAtom.reportChanged();
    }, _$currentAtom, name: '${_$currentAtom.name}_set');
  }

  final _$UserLangBaseActionController = ActionController(name: 'UserLangBase');

  @override
  void setLang(String lang) {
    final _$actionInfo = _$UserLangBaseActionController.startAction();
    try {
      return super.setLang(lang);
    } finally {
      _$UserLangBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string = 'current: ${current.toString()}';
    return '{$string}';
  }
}
