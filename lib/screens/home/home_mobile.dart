import 'package:figstyle/screens/add_quote/steps.dart';
import 'package:figstyle/screens/favourites.dart';
import 'package:figstyle/screens/notifications_center.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/types/topic_color.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:figstyle/utils/navigation_helper.dart';
import 'package:figstyle/utils/storage_keys.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/utils/icons_more_icons.dart';
import 'package:figstyle/screens/dashboard.dart';
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
import 'package:supercharged/supercharged.dart';

class HomeMobile extends StatefulWidget {
  final int initialIndex;

  HomeMobile({
    this.initialIndex = 0,
  });

  @override
  _HomeMobileState createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  int selectedIndex = 0;
  Color accentColor = stateColors.secondary;

  static List<Widget> _listScreens = <Widget>[
    RecentQuotes(
      showNavBackIcon: false,
    ),
    Search(),
    Discover(),
    Topics(),
    Dashboard(),
  ];

  ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedIndex = widget.initialIndex;
    });

    initColors();
    initQuickActions();
    mayOpenQuote();
    mayOpenNotificationsCenter();
  }

  @override
  void dispose() {
    reactionDisposer?.reaction?.dispose();
    super.dispose();
  }

  void initColors() {
    final tColor = appTopicsColors.shuffle(max: 1).firstOrElse(
          () => TopicColor.fromJSON(
            {
              'name': 'blue',
              'color': Colors.blue.value,
            },
          ),
        );

    setState(() {
      accentColor = Color(tColor.decimal) ?? accentColor;
    });
  }

  void initQuickActions() {
    final quickActions = QuickActions();

    quickActions.initialize((String startRoute) {
      if (startRoute == 'action_search') {
        setState(() {
          selectedIndex = 1;
        });

        return;
      }

      if (startRoute == 'action_add_quote') {
        NavigationHelper.navigateNextFrame(
          MaterialPageRoute(builder: (_) => AddQuoteSteps()),
          context,
        );

        return;
      }

      if (startRoute == 'action_favourites') {
        NavigationHelper.navigateNextFrame(
          MaterialPageRoute(builder: (_) => Favourites()),
          context,
        );

        return;
      }
    });

    reactionDisposer = autorun((_) {
      if (userState.isUserConnected) {
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
      body: Container(
        child: _listScreens.elementAt(selectedIndex),
      ),
      bottomNavigationBar: SnakeNavigationBar.color(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        snakeViewColor: accentColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: accentColor,
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

  void mayOpenQuote() {
    final val = appStorage.getString(StorageKeys.quoteIdNotification) ?? '';

    if (val.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        appStorage.setString(StorageKeys.quoteIdNotification, '');

        showCupertinoModalBottomSheet(
          context: context,
          builder: (context, scrollController) => QuotePage(
            padding: const EdgeInsets.only(left: 10.0),
            quoteId: val,
            scrollController: scrollController,
          ),
        );
      });
    }
  }

  void mayOpenNotificationsCenter() {
    final notifiPath =
        appStorage.getString(StorageKeys.onOpenNotificationPath) ?? '';

    if (notifiPath.isNotEmpty) {
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
            builder: (context, scrollController) => NotificationsCenter(),
          );
        }
      });
    }
  }
}
