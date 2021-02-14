import 'dart:io';

import 'package:figstyle/screens/home/home_minimal_recent.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home_mobile.dart';

class Home extends StatefulWidget {
  final int mobileInitialIndex;

  Home({this.mobileInitialIndex = 0});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) => LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < Constants.maxMobileWidth ||
                  constraints.maxHeight < Constants.maxMobileWidth) {
                return HomeMobile(
                  initialIndex: widget.mobileInitialIndex,
                );
              }

              // Mostly for tablets: iPad, Android tablet
              if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
                return HomeMobile(
                  initialIndex: widget.mobileInitialIndex,
                );
              }

              return HomeMinimalRecent();
            },
          ),
        ),
      ],
    );
  }
}
