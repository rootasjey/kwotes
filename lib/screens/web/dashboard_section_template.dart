import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/ColoredListTile.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';

class DashboardSectionTemplate extends StatefulWidget {
  final Widget child;
  final String childName;
  final bool isNested;

  DashboardSectionTemplate({
    this.child,
    this.childName = '',
    this.isNested = false,
  });

  @override
  _DashboardSectionTemplateState createState() => _DashboardSectionTemplateState();
}

class _DashboardSectionTemplateState extends State<DashboardSectionTemplate> {
  //  Current State of InnerDrawerState
  // final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // final screenWidth = MediaQuery.of(context).size.width;
        return wideView();
      },
    );
  }

  Widget wideView() {
    return Material(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.05),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Stack(
                children: <Widget>[
                  ListView(
                  children: <Widget>[
                    sideBarHeader(),

                    Padding(padding: const EdgeInsets.only(bottom: 100.0)),

                    ColoredListTile(
                      icon: Icons.favorite,
                      outlined: false,
                      selected: widget.childName == FavouritesRoute,
                      hoverColor: Colors.red,
                      title: Text(
                        'Favourites',
                      ),
                      onTap: () => navigateToSection(FavouritesRoute),
                    ),

                    ColoredListTile(
                      icon: Icons.list,
                      outlined: false,
                      hoverColor: Colors.blue.shade700,
                      selected: widget.childName == ListsRoute,
                      title: Text(
                        'Lists',
                      ),
                      onTap: () => navigateToSection(ListsRoute),
                    ),

                    ColoredListTile(
                      icon: Icons.edit,
                      outlined: false,
                      hoverColor: Colors.purple.shade300,
                      selected: widget.childName == DraftsRoute,
                      title: Text(
                        'Drafts',
                      ),
                      onTap: () => navigateToSection(DraftsRoute),
                    ),

                    ColoredListTile(
                      icon: Icons.cloud_done,
                      outlined: false,
                      hoverColor: Colors.green,
                      selected: widget.childName == PublishedQuotesRoute,
                      title: Text(
                        'Published',
                      ),
                      onTap: () => navigateToSection(PublishedQuotesRoute),
                    ),

                    ColoredListTile(
                      icon: Icons.timelapse,
                      outlined: false,
                      hoverColor: Colors.lightBlue.shade900,
                      selected: widget.childName == TempQuotesRoute,
                      title: Text(
                        'In Validation',

                      ),
                      onTap: () => navigateToSection(TempQuotesRoute),
                    ),

                    Padding(padding: const EdgeInsets.only(bottom: 100.0),),
                  ],
                ),

                  Positioned(
                    left: 15.0,
                    bottom: 20.0,
                    child: RaisedButton(
                      onPressed: () {
                        AddQuoteInputs.clearAll();
                        AddQuoteInputs.navigatedFromPath = 'dashboard';
                        FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
                      },
                      color: stateColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.add, color: Colors.white),
                            Padding(padding: const EdgeInsets.only(left: 10.0),),
                            Text(
                              'Propose new quote',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void navigateToSection(String route) {
    if (widget.childName == route && !widget.isNested) {
      return;
    }

    FluroRouter.router.navigateTo(
      context,
      route,
      transition: TransitionType.fadeIn,
    );
  }

  sideBarHeader() {
    return ListTile(
      leading: Observer(
        builder: (context) {
          if (userState.avatarUrl.isEmpty) {
            final arrStr = userState.username.split(' ');
              String initials = '';


              if (arrStr.length > 0) {
                initials = arrStr.length > 1
                ? arrStr.reduce((value, element) => value + element.substring(1))
                : arrStr.first;

                if (initials != null && initials.isNotEmpty) {
                  initials = initials.substring(0, 1);
                }
              }

              return CircleAvatar(
                backgroundColor: stateColors.primary,
                radius: 20.0,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }

            return CircleAvatar(
              backgroundColor: stateColors.primary,
              // backgroundImage: AssetImage(userState.avatarUrl,),
              radius: 20.0,
              child: Image.asset(
                userState.avatarUrl,
                width: 20.0,
              ),
            );
        },
      ),
      title: Tooltip(
        message: userState.username,
        child: Text(
          userState.username,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.keyboard_arrow_down),
        tooltip: 'Menu',
        onSelected: (value) {
          if (value == 'signout') {
            userSignOut(context: context);
            return;
          }

          FluroRouter.router.navigateTo(
            context,
            value,
          );
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem(
            value: AccountRoute,
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: 'signout',
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Sign out',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: RootRoute,
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  // Widget innerDrawerView() {
  //   return InnerDrawer(
  //     key: _innerDrawerKey,
  //     tapScaffoldEnabled: true,
  //     offset: IDOffset.only(
  //       left: 0.0,
  //     ),
  //     leftChild: Container(
  //       width: 250.0,
  //       child: Material(
  //         child: ListView(
  //           children: <Widget>[
  //             ListTile(
  //               title: Text('Item 1'),
  //             ),
  //             ListTile(
  //               title: Text('Item 2'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     scaffold: widget.child,
  //   );
  // }
}
