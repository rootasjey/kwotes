
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

  Color primary = Color(0xFF796AD2);

  @action
  void refreshTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      foreground = Colors.white;
      background = Colors.black;
      return;
    }

    foreground = Colors.black;
    background = Colors.white;
  }
}

final stateColors = StateColors();
