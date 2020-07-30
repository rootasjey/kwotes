import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';

class SideBarHeader extends StatefulWidget {
  @override
  _SideBarHeaderState createState() => _SideBarHeaderState();
}

class _SideBarHeaderState extends State<SideBarHeader> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return userState.isUserConnected
          ? authenticatedView()
          : guestView();
      }
    );
  }

  Widget authenticatedView() {
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
            radius: 20.0,
            backgroundColor: stateColors.softBackground,
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

        ],
      ),
    );
  }

  Widget guestView() {
    return Row(
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            FluroRouter.router.navigateTo(
              context,
              SigninRoute,
            );
          },
          color: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(7.0),
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
            FluroRouter.router.navigateTo(
              context,
              value,
            );
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          ],
        ),
      ],
    );
  }
}
