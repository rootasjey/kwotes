import 'dart:async';

import 'package:figstyle/screens/on_boarding.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home_desktop.dart';
import 'package:figstyle/screens/home/home_mobile.dart';
import 'package:supercharged/supercharged.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool firstLaunch = false;

  @override
  initState() {
    super.initState();
    setState(() {
      firstLaunch = appStorage.isFirstLanch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            if (firstLaunch && constraints.maxWidth > 700.0) {
              firstLaunch = false;
              appStorage.setFirstLaunch();

              Timer(2.seconds, () {
                showFlash(
                  context: context,
                  persistent: false,
                  builder: (context, controller) {
                    return Flash.dialog(
                      controller: controller,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      enableDrag: true,
                      margin: const EdgeInsets.only(
                        left: 120.0,
                        right: 120.0,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      child: FlashBar(
                        message: Container(
                          height: MediaQuery.of(context).size.height - 100.0,
                          padding: const EdgeInsets.all(60.0),
                          child: OnBoarding(isDesktop: true),
                        ),
                      ),
                    );
                  },
                );
              });

              return homeView(constraints.maxWidth);
            }

            if (firstLaunch) {
              firstLaunch = false;
              appStorage.setFirstLaunch();
              return OnBoarding();
            }

            return homeView(constraints.maxWidth);
          });
        }),
      ],
    );
  }

  Widget homeView(double maxWidth) {
    if (maxWidth < 700.0) {
      return firstLaunch ? OnBoarding() : HomeMobile();
    }

    return HomeDesktop();
  }
}
