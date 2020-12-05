import 'dart:async';
import 'dart:io';

import 'package:figstyle/screens/on_boarding.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/home/home_desktop.dart';
import 'package:figstyle/screens/home/home_mobile.dart';
import 'package:mobx/mobx.dart';
import 'package:supercharged/supercharged.dart';

class Home extends StatefulWidget {
  final int mobileInitialIndex;

  Home({this.mobileInitialIndex = 0});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isFirstLaunch = false;
  bool isPopupVisible = false;
  FlashController popupController;

  ReactionDisposer reactionDisposer;

  @override
  initState() {
    super.initState();

    userState.setFirstLaunch(appStorage.isFirstLanch());

    reactionDisposer = autorun((reaction) {
      isFirstLaunch = userState.isFirstLaunch;
    });
  }

  @override
  void dispose() {
    reactionDisposer?.reaction?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) => LayoutBuilder(
            builder: (context, constraints) {
              if (mustShowOnBoardingDesktop(constraints.maxWidth)) {
                isPopupVisible = true;
                showDesktopDialog(context);
                return homeView(constraints);
              }

              if (mustShowOnBoardingMobile(constraints.maxWidth)) {
                if (mustHidePopup()) {
                  isPopupVisible = false;
                  popupController.dismiss();
                }

                return OnBoarding();
              }

              return homeView(constraints);
            },
          ),
        ),
      ],
    );
  }

  Widget homeView(BoxConstraints constraints) {
    if (constraints.maxWidth < Constants.maxMobileWidth ||
        constraints.maxHeight < Constants.maxMobileWidth) {
      return HomeMobile(
        initialIndex: widget.mobileInitialIndex,
      );
    }

    // Mostly for iPad
    if (Platform.isIOS) {
      return HomeMobile(
        initialIndex: widget.mobileInitialIndex,
      );
    }

    return HomeDesktop();
  }

  void showDesktopDialog(customContext) {
    Timer(
      2.seconds,
      () {
        showFlash(
          context: customContext,
          persistent: false,
          onWillPop: () {
            appStorage.setFirstLaunch();
            userState.setFirstLaunch(false);
            return Future.value(false);
          },
          builder: (context, controller) {
            popupController = controller;

            return Flash.dialog(
              controller: controller,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      },
    );
  }

  bool mustShowOnBoardingDesktop(double maxWidth) {
    return !isPopupVisible && isFirstLaunch && maxWidth > 700.0;
  }

  bool mustHidePopup() {
    return isPopupVisible &&
        popupController != null &&
        !popupController.isDisposed;
  }

  bool mustShowOnBoardingMobile(double maxWidth) {
    return isFirstLaunch && maxWidth < 700.0;
  }
}
