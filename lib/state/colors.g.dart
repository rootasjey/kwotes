// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colors.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StateColors on StateColorsBase, Store {
  final _$accentAtom = Atom(name: 'StateColorsBase.accent');

  @override
  Color get accent {
    _$accentAtom.reportRead();
    return super.accent;
  }

  @override
  set accent(Color value) {
    _$accentAtom.reportWrite(value, super.accent, () {
      super.accent = value;
    });
  }

  final _$appBackgroundAtom = Atom(name: 'StateColorsBase.appBackground');

  @override
  Color get appBackground {
    _$appBackgroundAtom.reportRead();
    return super.appBackground;
  }

  @override
  set appBackground(Color value) {
    _$appBackgroundAtom.reportWrite(value, super.appBackground, () {
      super.appBackground = value;
    });
  }

  final _$backgroundAtom = Atom(name: 'StateColorsBase.background');

  @override
  Color get background {
    _$backgroundAtom.reportRead();
    return super.background;
  }

  @override
  set background(Color value) {
    _$backgroundAtom.reportWrite(value, super.background, () {
      super.background = value;
    });
  }

  final _$foregroundAtom = Atom(name: 'StateColorsBase.foreground');

  @override
  Color get foreground {
    _$foregroundAtom.reportRead();
    return super.foreground;
  }

  @override
  set foreground(Color value) {
    _$foregroundAtom.reportWrite(value, super.foreground, () {
      super.foreground = value;
    });
  }

  final _$iconExtAtom = Atom(name: 'StateColorsBase.iconExt');

  @override
  String get iconExt {
    _$iconExtAtom.reportRead();
    return super.iconExt;
  }

  @override
  set iconExt(String value) {
    _$iconExtAtom.reportWrite(value, super.iconExt, () {
      super.iconExt = value;
    });
  }

  final _$softBackgroundAtom = Atom(name: 'StateColorsBase.softBackground');

  @override
  Color get softBackground {
    _$softBackgroundAtom.reportRead();
    return super.softBackground;
  }

  @override
  set softBackground(Color value) {
    _$softBackgroundAtom.reportWrite(value, super.softBackground, () {
      super.softBackground = value;
    });
  }

  final _$StateColorsBaseActionController =
      ActionController(name: 'StateColorsBase');

  @override
  void setAccentColor(Color color) {
    final _$actionInfo = _$StateColorsBaseActionController.startAction(
        name: 'StateColorsBase.setAccentColor');
    try {
      return super.setAccentColor(color);
    } finally {
      _$StateColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void refreshTheme(Brightness brightness) {
    final _$actionInfo = _$StateColorsBaseActionController.startAction(
        name: 'StateColorsBase.refreshTheme');
    try {
      return super.refreshTheme(brightness);
    } finally {
      _$StateColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
accent: ${accent},
appBackground: ${appBackground},
background: ${background},
foreground: ${foreground},
iconExt: ${iconExt},
softBackground: ${softBackground}
    ''';
  }
}
