import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddQuoteAppBar extends StatefulWidget {
  final Function onTapIconHeader;
  final String title;

  /// If specified, show an icon button which will show
  /// a bottom sheet containing this widget content.
  final Widget help;

  final bool isNarrow;
  final EdgeInsets padding;

  AddQuoteAppBar({
    this.help,
    this.isNarrow = false,
    this.onTapIconHeader,
    this.padding = EdgeInsets.zero,
    this.title = '',
  });

  @override
  _AddQuoteAppBarState createState() => _AddQuoteAppBarState();
}

class _AddQuoteAppBarState extends State<AddQuoteAppBar> {
  @override
  Widget build(BuildContext context) {
    final leftPadding = widget.isNarrow ? 0.0 : 60.0;

    return AppBar(
      backgroundColor: stateColors.appBackground.withOpacity(1.0),
      automaticallyImplyLeading: false,
      toolbarHeight: 80.0,
      title: Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
        ),
        child: Row(
          children: <Widget>[
            if (context.router.root.stack.length > 1)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  color: stateColors.foreground,
                  onPressed: () => context.router.pop(),
                  icon: Icon(Icons.arrow_back),
                ),
              ),
            AppIcon(
              size: 40.0,
              padding: EdgeInsets.zero,
              onTap: () => context.router.root.navigate(HomeRoute()),
            ),
            if (widget.title.isNotEmpty) titleBar(isNarrow: widget.isNarrow),
          ],
        ),
      ),
      actions: [
        helpButton(),
        if (!widget.isNarrow) userMenu(widget.isNarrow),
      ],
    );
  }

  Widget helpButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CircleButton(
        elevation: 2.0,
        backgroundColor: stateColors.softBackground,
        icon: Icon(
          Icons.help_outline,
          size: 20.0,
          color: stateColors.primary,
        ),
        onTap: () => showCupertinoModalBottomSheet(
          context: context,
          builder: (context) {
            final padding =
                MediaQuery.of(context).size.width < 600.0 ? 20.0 : 40.0;

            return Scaffold(
              body: SingleChildScrollView(
                controller: ModalScrollController.of(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleButton(
                            onTap: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              size: 20.0,
                              color: stateColors.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Help',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    'Some useful informaton about the current step',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20.0,
                      thickness: 2.0,
                      color: stateColors.primary,
                    ),
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: widget.help,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget titleBar({bool isNarrow = false}) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0),
      child: isNarrow
          ? Tooltip(
              message: widget.title,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : Opacity(
              opacity: 0.6,
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: stateColors.foreground,
                ),
              ),
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
        right: 20.0,
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

          switch (value) {
            case RouteNames.FavouritesRoute:
              context.router.root.navigate(
                DashboardPageRoute(children: [FavouritesRoute()]),
              );
              break;
            case RouteNames.ListsRoute:
              context.router.root.navigate(
                DashboardPageRoute(children: [QuotesListsRoute()]),
              );
              break;
            case RouteNames.DraftsRoute:
              context.router.root.navigate(
                DashboardPageRoute(children: [DraftsRoute()]),
              );
              break;
            case RouteNames.PublishedQuotesRoute:
              context.router.root.navigate(
                DashboardPageRoute(children: [MyPublishedQuotesRoute()]),
              );
              break;
            case RouteNames.TempQuotesRoute:
              context.router.root.navigate(
                DashboardPageRoute(children: [MyTempQuotesRoute()]),
              );
              break;
            case RouteNames.AccountRoute:
              context.router.root.navigate(
                SettingsRoute(),
              );
              break;
            default:
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem(
              value: RouteNames.FavouritesRoute,
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text(
                  'Favourites',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
              value: RouteNames.ListsRoute,
              child: ListTile(
                leading: Icon(Icons.list),
                title: Text(
                  'Lists',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
            value: RouteNames.DraftsRoute,
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Drafts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
            value: RouteNames.PublishedQuotesRoute,
            child: ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text(
                'Published',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const PopupMenuItem(
              value: RouteNames.TempQuotesRoute,
              child: ListTile(
                leading: Icon(Icons.timelapse),
                title: Text(
                  'In Validation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          const PopupMenuItem(
            value: RouteNames.AccountRoute,
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

  Widget userMenu(bool isNarrow) {
    return Observer(builder: (context) {
      if (stateUser.isUserConnected) {
        return userAvatar(isNarrow: isNarrow);
      }

      return Padding(padding: EdgeInsets.zero);
    });
  }
}
