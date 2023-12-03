import "dart:io";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/menu_navigation_item.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/globals/utils/passage.dart";
import "package:kwotes/screens/dashboard/dashboard_page.dart";
import "package:kwotes/screens/home/home_navigation_page.dart";
import "package:kwotes/screens/search/search_navigation_page.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:salomon_bottom_bar/salomon_bottom_bar.dart";
import "package:unicons/unicons.dart";

class AppLocationContainer extends StatefulWidget {
  /// App container with deep locations and navigation bar.
  const AppLocationContainer({
    super.key,
  });

  @override
  State<AppLocationContainer> createState() => _AppLocationContainerState();
}

class _AppLocationContainerState extends State<AppLocationContainer> {
  /// Previous brightness.
  Brightness? _previousBrightness;

  /// Current page index.
  int _currentIndex = 0;

  /// List of widget children.
  final List<StatefulWidget> _widgetChildren = [
    const HomeNavigationPage(),
    const SearchNavigationPage(),
    const DashboardPage(),
  ];

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    adaptUiOverlayStyle();
    final bool isMobile = Utils.measurements.isMobileSize(context);

    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final Signal<bool> signalNavigationBar =
        context.get<Signal<bool>>(EnumSignalId.navigationBar);

    if (isMobile) {
      return Scaffold(
        body: _widgetChildren[_currentIndex],
        bottomNavigationBar: SignalBuilder(
          signal: signalNavigationBar,
          builder: (BuildContext context, bool show, Widget? child) {
            if (show) {
              return child ?? const SizedBox.shrink();
            }

            return const SizedBox.shrink();
          },
          child: SalomonBottomBar(
            backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
            margin:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
            currentIndex: _currentIndex,
            onTap: onTapBottomBarItem,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(TablerIcons.home),
                title: Text("home".tr()),
                selectedColor: Constants.colors.home,
              ),
              SalomonBottomBarItem(
                icon: const Icon(UniconsLine.search),
                title: Text("search.name".tr()),
                selectedColor: Constants.colors.search,
              ),
              SalomonBottomBarItem(
                icon: const Icon(UniconsLine.user),
                title: Text("dashboard".tr()),
                selectedColor: Constants.colors.delete,
              ),
            ],
          ),
        ),
      );
    }

    final Signal<Color> appFrameColor = context.get<Signal<Color>>(
      EnumSignalId.appFrameColor,
    );

    return SignalBuilder(
      signal: appFrameColor,
      builder: (BuildContext context, Color backgroundColor, Widget? body) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: body,
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(8.0),
              child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                clipBehavior: Clip.antiAlias,
                child: _widgetChildren[_currentIndex],
              ),
            ),
          ),
          SignalBuilder(
            signal: signalNavigationBar,
            builder: (BuildContext context, bool show, Widget? child) {
              if (show) {
                return child ?? const SizedBox.shrink();
              }

              return const SizedBox.shrink();
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(8.0).subtract(
                const EdgeInsets.only(left: 8.0),
              ),
              child: Material(
                color: isDarkTheme ? Colors.black87 : Colors.white,
                elevation: isDarkTheme ? 4.0 : 0.0,
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                child: SizedBox(
                  width: 90.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MenuNavigationItem(
                        index: 0,
                        label: "home".tr(),
                        icon: const Icon(TablerIcons.home),
                        onTap: onTapBottomBarItem,
                        selectedColor: Constants.colors.home,
                        selected: _currentIndex == 0,
                        tooltip: "home".tr(),
                      ),
                      MenuNavigationItem(
                        icon: const Icon(TablerIcons.search),
                        index: 1,
                        label: "search.name".tr(),
                        onTap: onTapBottomBarItem,
                        selected: _currentIndex == 1,
                        selectedColor: Constants.colors.search,
                        tooltip: "search.name".tr(),
                      ),
                      MenuNavigationItem(
                        icon: const Icon(TablerIcons.user_circle),
                        index: 2,
                        label: "dashboard".tr(),
                        onTap: onTapBottomBarItem,
                        selected: _currentIndex == 2,
                        selectedColor: Constants.colors.delete,
                        tooltip: "dashboard".tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onTapBottomBarItem(int index) {
    setState(() => _currentIndex = index);
    Passage.homePageTabIndex = index;
    Utils.vault.setHomePageTabIndex(index);
  }

  /// Initialize page properties.
  void initProps() async {
    _currentIndex = Passage.homePageTabIndex;
  }

  /// Adapt UI overlay style on Android and iOS.
  void adaptUiOverlayStyle() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    final Brightness? currentBrightness =
        AdaptiveTheme.maybeOf(context)?.brightness;

    if (currentBrightness == null) {
      return;
    }

    if (currentBrightness == _previousBrightness) {
      return;
    }

    _previousBrightness = currentBrightness;

    final SystemUiOverlayStyle overlayStyle =
        currentBrightness == Brightness.dark
            ? SystemUiOverlayStyle(
                statusBarColor: Constants.colors.dark,
                systemNavigationBarColor: Color.alphaBlend(
                  Colors.black26,
                  Constants.colors.dark,
                ),
                systemNavigationBarDividerColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle(
                statusBarColor: Constants.colors.lightBackground,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarDividerColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              );

    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }
}
