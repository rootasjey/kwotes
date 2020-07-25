
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'colors.g.dart';

class StateColors = StateColorsBase with _$StateColors;

abstract class StateColorsBase with Store {
  @observable
  Color appBackground = Color(0xFAFAFA);

  @observable
  Color background = Colors.white;

  @observable
  Color foreground = Colors.black;

  @observable
  String iconExt = 'light';

  Color primary = Color(0xFF796AD2);

  @observable
  Color softBackground = Color(0xFFEEEEEE);

  ThemeData themeData;

  @action
  void refreshTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      foreground = Colors.white;
      background = Colors.black;
      appBackground = Color(0xFF303030);
      softBackground = Color(0xFF303030);
      iconExt = 'light';
      return;
    }

    foreground = Colors.black;
    background = Colors.white;
    appBackground = Color(0xFAFAFA);
    softBackground = Color(0xFFEEEEEE);
    iconExt = 'dark';
  }
}

final stateColors = StateColors();
