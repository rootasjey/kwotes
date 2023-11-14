import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/globals/utils/passage.dart";
import "package:kwotes/screens/dashboard/dashboard_page.dart";
import "package:kwotes/screens/home/desktop_home_page.dart";
import "package:kwotes/screens/home/home_navigation_page.dart";
import "package:kwotes/screens/search/search_navigation_page.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:salomon_bottom_bar/salomon_bottom_bar.dart";
import "package:unicons/unicons.dart";

class ResponsiveAppContainer extends StatefulWidget {
  const ResponsiveAppContainer({
    super.key,
  });

  @override
  State<ResponsiveAppContainer> createState() => _ResponsiveAppContainerState();
}

class _ResponsiveAppContainerState extends State<ResponsiveAppContainer> {
  /// Current page index.
  int _currentIndex = 0;

  /// List of widget children.
  final widgetChildren = [
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
    final bool isMobile = Utils.measurements.isMobileSize(context);

    if (!isMobile) {
      return const DesktopHomePage();
    }

    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final Signal<bool> signalNavigationBar =
        context.get<Signal<bool>>(EnumSignalId.navigationBar);

    return Scaffold(
      body: widgetChildren[_currentIndex],
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
          margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
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
              selectedColor: Constants.colors.bio,
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

  onTapBottomBarItem(int index) {
    setState(() {
      _currentIndex = index;
    });

    Passage.homePageTabIndex = index;
    Utils.vault.setHomePageTabIndex(index);
  }

  /// Initialize page properties.
  void initProps() async {
    _currentIndex = Passage.homePageTabIndex;
  }
}
