import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';

class SideBarHeader extends StatefulWidget {
  @override
  _SideBarHeaderState createState() => _SideBarHeaderState();
}

class _SideBarHeaderState extends State<SideBarHeader> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return stateUser.isUserConnected ? authenticatedView() : guestView();
    });
  }

  Widget authenticatedView() {
    return ListTile(
      leading: Observer(
        builder: (context) {
          if (stateUser.avatarUrl.isEmpty) {
            final arrStr = stateUser.username.split(' ');
            String initials = '';

            if (arrStr.length > 0) {
              initials = arrStr.length > 1
                  ? arrStr
                      .reduce((value, element) => value + element.substring(1))
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

          return Material(
            elevation: 4.0,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  stateUser.avatarUrl,
                  width: 50.0,
                ),
              ),
            ),
          );
        },
      ),
      title: Tooltip(
        message: stateUser.username,
        child: Text(
          stateUser.username,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.keyboard_arrow_down),
        tooltip: 'Menu',
        onSelected: (value) {
          if (value == 'signout') {
            stateUser.signOut(
              context: context,
              redirectOnComplete: true,
            );
            return;
          }

          switch (value) {
            case RouteNames.RootRoute:
              context.router.navigate(HomeRoute());
              break;
            case RouteNames.AccountRoute:
              context.router.navigate(SettingsRoute());
              break;
            default:
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem(
              value: RouteNames.RootRoute,
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  'Home',
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

  Widget guestView() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Signin()));
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
          ),
          child: Container(
            width: 100.0,
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        PopupMenuButton<String>(
          icon: Icon(Icons.keyboard_arrow_down),
          tooltip: 'Menu',
          onSelected: (value) {
            switch (value) {
              case RouteNames.RootRoute:
                context.router.navigate(HomeRoute());
                break;
              case RouteNames.AccountRoute:
                context.router.navigate(SettingsRoute());
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
                value: RouteNames.RootRoute,
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    'Home',
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
          ],
        ),
      ],
    );
  }
}
