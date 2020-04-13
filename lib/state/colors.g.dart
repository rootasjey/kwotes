// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colors.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StateColors on StateColorsBase, Store {
  final _$foregroundAtom = Atom(name: 'StateColorsBase.foreground');

  @override
  Color get foreground {
    _$foregroundAtom.context.enforceReadPolicy(_$foregroundAtom);
    _$foregroundAtom.reportObserved();
    return super.foreground;
  }

  @override
  set foreground(Color value) {
    _$foregroundAtom.context.conditionallyRunInAction(() {
      super.foreground = value;
      _$foregroundAtom.reportChanged();
    }, _$foregroundAtom, name: '${_$foregroundAtom.name}_set');
  }

  final _$backgroundAtom = Atom(name: 'StateColorsBase.background');

  @override
  Color get background {
    _$backgroundAtom.context.enforceReadPolicy(_$backgroundAtom);
    _$backgroundAtom.reportObserved();
    return super.background;
  }

  @override
  set background(Color value) {
    _$backgroundAtom.context.conditionallyRunInAction(() {
      super.background = value;
      _$backgroundAtom.reportChanged();
    }, _$backgroundAtom, name: '${_$backgroundAtom.name}_set');
  }

  final _$softBackgroundAtom = Atom(name: 'StateColorsBase.softBackground');

  @override
  Color get softBackground {
    _$softBackgroundAtom.context.enforceReadPolicy(_$softBackgroundAtom);
    _$softBackgroundAtom.reportObserved();
    return super.softBackground;
  }

  @override
  set softBackground(Color value) {
    _$softBackgroundAtom.context.conditionallyRunInAction(() {
      super.softBackground = value;
      _$softBackgroundAtom.reportChanged();
    }, _$softBackgroundAtom, name: '${_$softBackgroundAtom.name}_set');
  }

  final _$iconExtAtom = Atom(name: 'StateColorsBase.iconExt');

  @override
  String get iconExt {
    _$iconExtAtom.context.enforceReadPolicy(_$iconExtAtom);
    _$iconExtAtom.reportObserved();
    return super.iconExt;
  }

  @override
  set iconExt(String value) {
    _$iconExtAtom.context.conditionallyRunInAction(() {
      super.iconExt = value;
      _$iconExtAtom.reportChanged();
    }, _$iconExtAtom, name: '${_$iconExtAtom.name}_set');
  }

  final _$StateColorsBaseActionController =
      ActionController(name: 'StateColorsBase');

  @override
  void refreshTheme(Brightness brightness) {
    final _$actionInfo = _$StateColorsBaseActionController.startAction();
    try {
      return super.refreshTheme(brightness);
    } finally {
      _$StateColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'foreground: ${foreground.toString()},background: ${background.toString()},softBackground: ${softBackground.toString()},iconExt: ${iconExt.toString()}';
    return '{$string}';
  }
}
