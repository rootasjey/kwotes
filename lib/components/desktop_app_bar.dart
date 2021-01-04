import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:figstyle/screens/search.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/brightness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/router/rerouter.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/screens/add_quote/steps.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/screens/signup.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';

class DesktopAppBar extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final bool showUserMenu;
  final bool showCloseButton;
  final bool pinned;

  final EdgeInsets padding;

  final Function onTapIconHeader;

  final String title;

  DesktopAppBar({
    this.automaticallyImplyLeading = false,
    this.onTapIconHeader,
    this.padding = EdgeInsets.zero,
    this.pinned = true,
    this.showCloseButton = false,
    this.showUserMenu = true,
    this.title = '',
  });

  @override
  _DesktopAppBarState createState() => _DesktopAppBarState();
}

class _DesktopAppBarState extends State<DesktopAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        final isNarrow = constrains.crossAxisExtent < 600.0;

        bool showUserMenu = !isNarrow;

        if (widget.showUserMenu != null) {
          showUserMenu = widget.showUserMenu;
        }

        return Observer(
          builder: (_) {
            final userSectionWidgets = List<Widget>();

            if (stateUser.isUserConnected) {
              isNarrow
                  ? userSectionWidgets.add(userAvatar(isNarrow: isNarrow))
                  : userSectionWidgets.addAll([
                      brightnessButton(),
                      searchButton(),
                      newQuoteButton(),
                      userAvatar(),
                    ]);
            } else {
              isNarrow
                  ? userSectionWidgets.add(userSigninMenu())
                  : userSectionWidgets.addAll([
                      searchButton(),
                      brightnessButton(),
                      Padding(
                        padding: const EdgeInsets.only(right: 60.0),
                        child: IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Signin()),
                          ),
                          color: stateColors.foreground,
                          tooltip: 'Sign in',
                          icon: Icon(Icons.login),
                        ),
                      ),
                    ]);
            }

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    if (widget.automaticallyImplyLeading)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IconButton(
                          color: stateColors.foreground,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back),
                        ),
                      ),
                    AppIcon(
                      size: 30.0,
                      padding: EdgeInsets.zero,
                      onTap: widget.onTapIconHeader,
                    ),
                    if (widget.title.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: Opacity(
                            opacity: 0.6,
                            child: Text(
                              widget.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: stateColors.foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget newQuoteButton() {
    return IconButton(
      tooltip: "New quote",
      onPressed: () {
        DataQuoteInputs.clearAll();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
      },
      color: stateColors.foreground,
      icon: Icon(Icons.add),
    );
  }

  Widget searchButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        tooltip: 'Search',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Search(),
            ),
          );
        },
        color: stateColors.foreground,
        icon: Icon(Icons.search),
      ),
    );
  }

  Widget signupButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FlatButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Signup()));
        },
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

  Widget signinButton() {
    return RaisedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => Signin()));
      },
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

  Widget userAvatar({bool isNarrow = true}) {
    final arrStr = stateUser.username.split(' ');
    String initials = '';

    if (arrStr.length > 0) {
      initials = arrStr.length > 1
          ? arrStr.reduce((value, element) => value + element.substring(1))
          : arrStr.first;

      if (initials != null && initials.isNotEmpty) {
        initials = initials.substring(0, 1);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 60.0,
      ),
      child: PopupMenuButton<String>(
        icon: CircleAvatar(
          backgroundColor: stateColors.primary,
          radius: 20.0,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // tooltip: 'More quick links',
        onSelected: (value) {
          if (value == 'signout') {
            userSignOut(context: context);
            return;
          }

          Rerouter.push(
            context: context,
            value: value,
          );
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          if (isNarrow)
            const PopupMenuItem(
                value: AddQuoteContentRoute,
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text(
                    'Add quote',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
          const PopupMenuItem(
              value: SearchRoute,
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text(
                  'Search',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
              value: FavouritesRoute,
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text(
                  'Favourites',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
              value: ListsRoute,
              child: ListTile(
                leading: Icon(Icons.list),
                title: Text(
                  'Lists',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
            value: DraftsRoute,
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Drafts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: PublishedQuotesRoute,
            child: ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text(
                'Published',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
              value: TempQuotesRoute,
              child: ListTile(
                leading: Icon(Icons.timelapse),
                title: Text(
                  'In Validation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
            value: AccountRoute,
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: 'signout',
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

  Widget userSection(bool isNarrow) {
    return Observer(builder: (context) {
      final children = List<Widget>();

      if (stateUser.isUserConnected) {
        isNarrow
            ? children.add(userAvatar(isNarrow: isNarrow))
            : children.addAll([
                userAvatar(),
                newQuoteButton(),
                searchButton(),
              ]);
      } else {
        isNarrow
            ? children.add(userSigninMenu())
            : children.addAll([
                signinButton(),
                signupButton(),
                searchButton(),
              ]);
      }

      return Container(
        padding: const EdgeInsets.only(
          top: 5.0,
          right: 10.0,
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: children,
        ),
      );
    });
  }

  Widget userSigninMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: SigninRoute,
          child: ListTile(
            leading: Icon(Icons.perm_identity),
            title: Text('Sign in'),
          ),
        ),
        PopupMenuItem(
          value: SignupRoute,
          child: ListTile(
            leading: Icon(Icons.open_in_browser),
            title: Text('Sign up'),
          ),
        ),
        PopupMenuItem(
          value: SearchRoute,
          child: ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
          ),
        ),
      ],
      onSelected: (value) {
        Rerouter.push(
          context: context,
          value: value,
        );
      },
    );
  }

  Widget closeButton() {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      color: Theme.of(context).iconTheme.color,
      icon: Icon(Icons.close),
    );
  }
}
