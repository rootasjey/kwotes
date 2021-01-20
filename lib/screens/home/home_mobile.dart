import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/screens/notifications_center.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:figstyle/utils/navigation_helper.dart';
import 'package:figstyle/utils/storage_keys.dart';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/utils/icons_more_icons.dart';
import 'package:figstyle/screens/dashboard_mobile_tab.dart';
import 'package:figstyle/screens/discover.dart';
import 'package:figstyle/screens/recent_quotes.dart';
import 'package:figstyle/screens/search.dart';
import 'package:figstyle/screens/topics.dart';
import 'package:figstyle/state/colors.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:mobx/mobx.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:quick_actions/quick_actions.dart';

class HomeMobile extends StatefulWidget {
  final int initialIndex;

  HomeMobile({
    this.initialIndex = 0,
  });

  @override
  _HomeMobileState createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> with WidgetsBindingObserver {
  int selectedIndex = 0;

  static List<Widget> _listScreens = <Widget>[
    RecentQuotes(
      showNavBackIcon: false,
    ),
    Search(),
    Discover(),
    Topics(),
    DashboardMobileTab(),
  ];

  ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    setState(() {
      selectedIndex = widget.initialIndex;
    });

    initQuickActions();
    mayOpenNotification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    reactionDisposer?.reaction?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      mayOpenNotification();
    }
  }

  void initQuickActions() {
    if (kIsWeb) {
      return;
    }

    final quickActions = QuickActions();

    quickActions.initialize((String startRoute) {
      if (startRoute == 'action_search') {
        setState(() {
          selectedIndex = 1;
        });

        return;
      }

      if (startRoute == 'action_add_quote') {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          context.router.root
              .navigate(DashboardPageRoute(children: [AddQuoteStepsRoute()]));
        });

        return;
      }

      if (startRoute == 'action_favourites') {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          context.router.root
              .navigate(DashboardPageRoute(children: [FavouritesRoute()]));
        });

        return;
      }
    });

    reactionDisposer = autorun((_) {
      if (stateUser.isUserConnected) {
        quickActions.setShortcutItems([
          ShortcutItem(
            type: 'action_add_quote',
            localizedTitle: 'New quote',
            icon: 'ic_shortcut_add',
          ),
          ShortcutItem(
            type: 'action_search',
            localizedTitle: 'Search',
            icon: 'ic_shortcut_search',
          ),
          ShortcutItem(
            type: 'action_favourites',
            localizedTitle: 'Favourites',
            icon: 'ic_shortcut_favorite',
          ),
        ]);
      } else {
        quickActions.setShortcutItems([
          ShortcutItem(
            type: 'action_search',
            localizedTitle: 'Search',
            icon: 'ic_shortcut_search',
          ),
        ]);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _listScreens.elementAt(selectedIndex),
      ),
      bottomNavigationBar: SnakeNavigationBar.color(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        snakeViewColor: stateColors.accent,
        selectedItemColor: Colors.white,
        unselectedItemColor: stateColors.accent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.timelapse,
            ),
            label: 'Recent',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.lightbulb_outline,
            ),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconsMore.tags,
            ),
            label: 'Topics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_identity,
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  void mayOpenNotification() {
    final notifiPath =
        appStorage.getString(StorageKeys.onOpenNotificationPath) ?? '';

    if (notifiPath.isEmpty) {
      return;
    }

    NavigationHelper.clearSavedNotifiData();

    if (notifiPath == 'notifications_center') {
      mayOpenNotificationsCenter();
    } else if (notifiPath == 'quote_page') {
      mayOpenQuote();
    }
  }

  void mayOpenQuote() {
    final quoteId = appStorage.getString(StorageKeys.quoteIdNotification) ?? '';

    if (quoteId.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        appStorage.setString(StorageKeys.quoteIdNotification, '');

        context.router.push(
          QuotesDeepRoute(children: [
            QuotePageRoute(
              quoteId: quoteId,
            )
          ]),
        );
      });
    }
  }

  void mayOpenNotificationsCenter() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      appStorage.setString(StorageKeys.onOpenNotificationPath, '');

      final size = MediaQuery.of(context).size;

      if (size.width > Constants.maxMobileWidth &&
          size.height > Constants.maxMobileWidth) {
        showFlash(
          context: context,
          persistent: false,
          builder: (context, controller) {
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
                  child: NotificationsCenter(),
                ),
              ),
            );
          },
        );
      } else {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => NotificationsCenter(
            scrollController: ModalScrollController.of(context),
          ),
        );
      }
    });
  }
}
