import 'package:auto_route/auto_route.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/brightness.dart';
import 'package:figstyle/utils/language.dart';
import 'package:figstyle/utils/navigation_helper.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopAppBar extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final bool showUserMenu;
  final bool showCloseButton;
  final bool pinned;

  /// Show appication icon if true. Hide it if false. Default tot true.
  final bool showAppIcon;

  /// Control left padding of the first dropdown. Default to 32.0;
  final double leftPaddingFirstDropdown;

  final EdgeInsets padding;

  final Function onTapIconHeader;

  final String title;

  DesktopAppBar({
    this.automaticallyImplyLeading = true,
    this.onTapIconHeader,
    this.padding = EdgeInsets.zero,
    this.pinned = true,
    this.showAppIcon = true,
    this.showCloseButton = false,
    this.showUserMenu = true,
    this.title = '',
    this.leftPaddingFirstDropdown = 32.0,
  });

  @override
  _DesktopAppBarState createState() => _DesktopAppBarState();
}

class _DesktopAppBarState extends State<DesktopAppBar> {
  /// If true, use icon instead of text for PopupMenuButton.
  bool useIconButton = false;
  bool useGroupedDropdown = false;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        final isNarrow = constrains.crossAxisExtent < 600.0;
        useIconButton = constrains.crossAxisExtent < 1000.0;
        useGroupedDropdown = constrains.crossAxisExtent < 800.0;

        bool showUserMenu = !isNarrow;

        if (widget.showUserMenu != null) {
          showUserMenu = widget.showUserMenu;
        }

        return Observer(
          builder: (_) {
            final userSectionWidgets = <Widget>[];

            if (stateUser.isUserConnected) {
              userSectionWidgets.addAll(getAuthButtons(isNarrow));
            } else {
              userSectionWidgets.addAll(getGuestButtons(isNarrow));
            }

            final mustShowNavBack = widget.automaticallyImplyLeading &&
                context.router.root.stack.length > 1;

            return SliverAppBar(
              floating: true,
              snap: true,
              pinned: widget.pinned,
              toolbarHeight: 80.0,
              backgroundColor: stateColors.appBackground.withOpacity(1.0),
              automaticallyImplyLeading: false,
              actions: showUserMenu ? userSectionWidgets : [],
              title: Padding(
                padding: widget.padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    if (mustShowNavBack)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 16.0,
                        ),
                        child: IconButton(
                          color: stateColors.foreground,
                          onPressed: () => context.router.pop(),
                          icon: Icon(Icons.arrow_back),
                        ),
                      ),
                    if (widget.showAppIcon)
                      AppIcon(
                        size: 30.0,
                        padding: const EdgeInsets.only(left: 10.0),
                        onTap: widget.onTapIconHeader,
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: widget.leftPaddingFirstDropdown,
                      ),
                      child: quotesByDropdown(),
                    ),
                    if (useGroupedDropdown)
                      groupedDropdown()
                    else
                      ...separateDropdowns(),
                    if (widget.showCloseButton) closeButton(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Switch from dark to light and vice-versa.
  Widget brightnessButton() {
    IconData iconBrightness = Icons.brightness_auto;
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appStorage.getBrightness();

      iconBrightness = currentBrightness == Brightness.dark
          ? Icons.brightness_2
          : Icons.brightness_low;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        icon: Icon(
          iconBrightness,
          color: stateColors.foreground,
        ),
        tooltip: 'Brightness',
        onSelected: (value) {
          if (value == 'auto') {
            setAutoBrightness(context);
            return;
          }

          final brightness =
              value == 'dark' ? Brightness.dark : Brightness.light;

          setBrightness(context, brightness);
          DynamicTheme.of(context).setBrightness(brightness);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'auto',
            child: ListTile(
              leading: Icon(Icons.brightness_auto),
              title: Text('Auto'),
            ),
          ),
          const PopupMenuItem(
            value: 'dark',
            child: ListTile(
              leading: Icon(Icons.brightness_2),
              title: Text('Dark'),
            ),
          ),
          const PopupMenuItem(
            value: 'light',
            child: ListTile(
              leading: Icon(Icons.brightness_5),
              title: Text('Light'),
            ),
          ),
        ],
      ),
    );
  }

  Widget closeButton() {
    return IconButton(
      onPressed: context.router.pop,
      color: Theme.of(context).iconTheme.color,
      icon: Icon(Icons.close),
    );
  }

  Widget developersDropdown() {
    return PopupMenuButton(
      tooltip: 'Developers',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 5.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? Icon(Icons.computer, color: stateColors.foreground)
                  : Text(
                      'developers',
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                Icons.keyboard_arrow_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<AppBarDevelopers>>[
        developerEntry(
          value: AppBarDevelopers.github,
          icon: Icon(
            UniconsLine.github,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'GitHub',
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case AppBarDevelopers.github:
            launch('https://github.com/rootasjey/fig.style');
            break;
          default:
        }
      },
    );
  }

  Widget developerEntry({
    @required Widget icon,
    @required AppBarDevelopers value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget discoverDropdown() {
    return PopupMenuButton(
      tooltip: 'Discover',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? FaIcon(
                      FontAwesomeIcons.binoculars,
                      color: stateColors.foreground,
                    )
                  : Text(
                      'discover',
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                Icons.keyboard_arrow_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<PageRouteInfo>>[
        discoverEntry(
          value: QuotesDeepRoute(
            children: [RandomQuotesRoute()],
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              UniconsLine.arrow_random,
              color: stateColors.foreground.withOpacity(0.6),
            ),
          ),
          textData: 'random quotes',
        ),
      ],
      onSelected: (value) {
        context.router.root.navigate(value);
      },
    );
  }

  Widget discoverEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  List<Widget> getAuthButtons(bool isNarrow) {
    if (isNarrow) {
      return [userAvatar(isNarrow: isNarrow)];
    }

    return [
      langButton(),
      brightnessButton(),
      searchButton(),
      newQuoteButton(),
      userAvatar(),
    ];
  }

  Iterable<Widget> getGuestButtons(bool isNarrow) {
    if (isNarrow) {
      return [userSigninMenu()];
    }

    return [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Center(
          child: OutlinedButton(
            onPressed: () => context.router.root.push(SigninRoute()),
            child: Text('Sign in'),
          ),
        ),
      ),
      searchButton(),
      brightnessButton(),
      settingsButton(),
    ];
  }

  Widget groupedSectionEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget groupedDropdown() {
    return PopupMenuButton(
      tooltip: 'More',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.more_horiz, color: stateColors.foreground),
              Icon(Icons.keyboard_arrow_down, color: stateColors.foreground),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<PageRouteInfo>>[
        groupedSectionEntry(
          value: HomeRoute(),
          icon: Icon(UniconsLine.home, color: stateColors.foreground),
          textData: 'home',
        ),
        groupedSectionEntry(
          value: QuotesDeepRoute(children: [RandomQuotesRoute()]),
          icon: Icon(UniconsLine.arrow_random, color: stateColors.foreground),
          textData: 'random quotes',
        ),
        PopupMenuDivider(),
        groupedSectionEntry(
          value: GitHubRoute(),
          icon: Icon(UniconsLine.github, color: stateColors.foreground),
          textData: 'GitHub',
        ),
        PopupMenuDivider(),
        groupedSectionEntry(
          value: AboutRoute(),
          icon: Icon(Icons.help_outline, color: stateColors.foreground),
          textData: 'about',
        ),
        groupedSectionEntry(
          value: ContactRoute(),
          icon: Icon(Icons.sms_outlined, color: stateColors.foreground),
          textData: 'contact',
        ),
        groupedSectionEntry(
          value: TosRoute(),
          icon: Icon(Icons.privacy_tip_outlined, color: stateColors.foreground),
          textData: 'Privacy Terms',
        ),
      ],
      onSelected: (PageRouteInfo pageRouteInfo) {
        if (pageRouteInfo.routeName == 'GitHubRoute') {
          launch('https://github.com/rootasjey/fig.style');
          return;
        }

        context.router.root.navigate(pageRouteInfo);
      },
    );
  }

  Widget langButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        tooltip: "Change language",
        icon: Icon(
          UniconsLine.language,
          color: stateColors.foreground,
        ),
        onSelected: (newValue) {
          Language.setLang(newValue);
          showSnack(
            context: context,
            message: "Your language has been successfully updated"
                " to ${Language.frontend(newValue)}",
            type: SnackType.success,
          );
        },
        itemBuilder: (context) => Language.available().map((value) {
          final isSelected = stateUser.lang == value;

          return PopupMenuItem(
            value: value,
            child: ListTile(
              trailing: isSelected ? Icon(UniconsLine.check) : null,
              title: Text(
                Language.frontend(value),
                style: TextStyle(
                  color:
                      isSelected ? stateColors.primary : stateColors.foreground,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget newQuoteButton() {
    return IconButton(
      tooltip: "New quote",
      onPressed: () {
        DataQuoteInputs.clearAll();
        context.router.root.navigate(
          DashboardPageRoute(children: [AddQuoteStepsRoute()]),
        );
      },
      color: stateColors.foreground,
      icon: Icon(Icons.add),
    );
  }

  Widget quotesByDropdown() {
    return PopupMenuButton(
      tooltip: 'Quotes by...',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? Icon(
                      Icons.format_quote_rounded,
                      color: stateColors.foreground,
                    )
                  : Text(
                      'quotes',
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                Icons.keyboard_arrow_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<AppBarQuotesBy>>[
        quotesByEntry(
          value: AppBarQuotesBy.authors,
          icon: Icon(
            Icons.person_outline,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'by authors',
        ),
        quotesByEntry(
          value: AppBarQuotesBy.references,
          icon: Icon(
            UniconsLine.bookmark,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'by references',
        ),
        quotesByEntry(
          value: AppBarQuotesBy.topics,
          icon: Icon(
            UniconsLine.circle,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'by topics',
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case AppBarQuotesBy.authors:
            context.router.root
                .push(AuthorsDeepRoute(children: [AuthorsRoute()]));
            break;
          case AppBarQuotesBy.references:
            context.router.root
                .push(ReferencesDeepRoute(children: [ReferencesRoute()]));
            break;
          case AppBarQuotesBy.topics:
            final topicName = appTopicsColors.shuffle(max: 1).first.name;

            context.router.root.push(
              TopicsDeepRoute(
                children: [
                  TopicPageRoute(
                    topicName: topicName,
                  )
                ],
              ),
            );
            break;
          default:
        }
      },
    );
  }

  Widget quotesByEntry({
    @required Widget icon,
    @required AppBarQuotesBy value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget resourcesDropdown() {
    return PopupMenuButton(
      tooltip: 'Resources',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? Icon(Icons.menu_book, color: stateColors.foreground)
                  : Text(
                      'resources',
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                Icons.keyboard_arrow_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<AppBarResources>>[
        resourcesEntry(
          value: AppBarResources.about,
          icon: Icon(
            Icons.help_outline,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'about',
        ),
        resourcesEntry(
          value: AppBarResources.contact,
          icon: Icon(
            Icons.sms_outlined,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'contact',
        ),
        resourcesEntry(
          value: AppBarResources.tos,
          icon: Icon(
            Icons.privacy_tip_outlined,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'Privacy Terms',
        ),
        PopupMenuDivider(),
        resourcesEntry(
          value: AppBarResources.androidApp,
          icon: FaIcon(
            FontAwesomeIcons.googlePlay,
            color: Colors.green,
          ),
          textData: 'Android app',
        ),
        resourcesEntry(
          value: AppBarResources.iosApp,
          icon: FaIcon(
            FontAwesomeIcons.appStoreIos,
            color: Colors.blue,
          ),
          textData: 'iOS app',
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case AppBarResources.about:
            context.router.root.push(AboutRoute());
            break;
          case AppBarResources.contact:
            context.router.root.push(ContactRoute());
            break;
          case AppBarResources.tos:
            context.router.root.push(TosRoute());
            break;
          case AppBarResources.androidApp:
            launch(
                "https://play.google.com/store/apps/details?id=com.outofcontext.app");
            break;
          case AppBarResources.iosApp:
            launch(
                "https://apps.apple.com/us/app/out-of-context/id1516117110?ls=1");
            break;
          default:
        }
      },
    );
  }

  Widget resourcesEntry({
    @required Widget icon,
    @required AppBarResources value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget searchButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        tooltip: 'Search',
        onPressed: () => context.router.root.push(SearchRoute()),
        color: stateColors.foreground,
        icon: Icon(Icons.search),
      ),
    );
  }

  List<Widget> separateDropdowns() {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: discoverDropdown(),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: developersDropdown(),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: resourcesDropdown(),
      ),
    ];
  }

  Widget settingsButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 60.0),
      child: PopupMenuButton(
        tooltip: 'Settings',
        icon: Icon(
          Icons.settings,
          color: stateColors.foreground,
        ),
        itemBuilder: (_) => <PopupMenuEntry<AppBarSettings>>[
          PopupMenuItem(
            value: AppBarSettings.allSettings,
            child: Text('All settings'),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: AppBarSettings.selectLang,
            enabled: false,
            child: Row(
              children: [
                Icon(
                  UniconsLine.language,
                  color: stateColors.foreground,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                ),
                Text('Language'),
              ],
            ),
          ),
          PopupMenuItem(
            value: AppBarSettings.en,
            child: Text('English'),
          ),
          PopupMenuItem(
            value: AppBarSettings.fr,
            child: Text('Français'),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case AppBarSettings.allSettings:
              context.router.root.push(SettingsRoute());
              break;
            case AppBarSettings.en:
              Language.setLang('en');
              showSnack(
                context: context,
                message: "Your language has been successfully updated"
                    " to ${Language.frontend('en')}",
                type: SnackType.success,
              );
              break;
            case AppBarSettings.fr:
              Language.setLang('fr');
              showSnack(
                context: context,
                message: "Your language has been successfully updated"
                    " to ${Language.frontend('fr')}",
                type: SnackType.success,
              );
              break;
            default:
          }
        },
      ),
    );
  }

  Widget signinButton() {
    return RaisedButton(
      onPressed: () => context.router.root.push(SigninRoute()),
      color: stateColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'SIGN IN',
              style: TextStyle(
                color: Colors.white,
                // fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signupButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FlatButton(
        onPressed: () => context.router.root.push(SignupRoute()),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Text(
            'SIGN UP',
          ),
        ),
      ),
    );
  }

  Widget userAvatar({bool isNarrow = true}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 60.0,
      ),
      child: PopupMenuButton<PageRouteInfo>(
        icon: Icon(
          UniconsLine.user_circle,
          color: stateColors.primary,
        ),
        tooltip: 'Show user menu',
        onSelected: (pageRouteInfo) {
          if (pageRouteInfo.routeName == SignOutRoute.name) {
            stateUser.signOut(
              context: context,
              redirectOnComplete: true,
            );
            return;
          }

          context.router.root.push(pageRouteInfo);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PageRouteInfo>>[
          if (isNarrow)
            PopupMenuItem(
              value: DashboardPageRoute(children: [AddQuoteStepsRoute()]),
              child: ListTile(
                leading: Icon(Icons.add),
                title: Text(
                  'Add quote',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const PopupMenuItem(
            value: SearchRoute(),
            child: ListTile(
              leading: Icon(Icons.search),
              title: Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: DashboardPageRoute(children: [FavouritesRoute()]),
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text(
                'Favourites',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: DashboardPageRoute(
              children: [
                QuotesListsDeepRoute(
                  children: [
                    QuotesListsRoute(),
                  ],
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text(
                'Lists',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: DashboardPageRoute(children: [DraftsRoute()]),
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Drafts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: DashboardPageRoute(children: [MyPublishedQuotesRoute()]),
            child: ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text(
                'Published',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: DashboardPageRoute(children: [MyTempQuotesRoute()]),
            child: ListTile(
              leading: Icon(Icons.timelapse),
              title: Text(
                'In Validation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PopupMenuItem(
            value: NavigationHelper.getSettingsRoute(),
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: SignOutRoute(),
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Sign out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userSigninMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => <PopupMenuEntry<PageRouteInfo>>[
        PopupMenuItem(
          value: SigninRoute(),
          child: ListTile(
            leading: Icon(Icons.perm_identity),
            title: Text('Sign in'),
          ),
        ),
        PopupMenuItem(
          value: SignupRoute(),
          child: ListTile(
            leading: Icon(Icons.open_in_browser),
            title: Text('Sign up'),
          ),
        ),
        PopupMenuItem(
          value: SearchRoute(),
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
          ),
        ),
      ],
      onSelected: (pageRouteInfo) {
        context.router.root.navigate(pageRouteInfo);
      },
    );
  }
}
