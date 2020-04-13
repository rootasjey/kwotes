
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'colors.g.dart';

class StateColors = StateColorsBase with _$StateColors;

abstract class StateColorsBase with Store {
  @observable
  Color foreground = Colors.black;

  @observable
  Color background = Colors.white;

  @observable
  Color softBackground = Color(0xFFEEEEEE);

  @observable
  String iconExt = 'light';

  Color primary = Color(0xFF796AD2);

  ThemeData themeData;

  @action
  void refreshTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      foreground = Colors.white;
      background = Colors.black;
      softBackground = Color(0xFF303030);
      iconExt = 'light';
      return;
    }

    foreground = Colors.black;
    background = Colors.white;
    softBackground = Color(0xFFEEEEEE);
    iconExt = 'dark';
  }
}

final stateColors = StateColors();
