import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';

class HomeAppBar extends StatefulWidget {
  final Function onTapIconHeader;
  HomeAppBar({
    this.onTapIconHeader,
  });

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          pinned: true,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(
              left: 60.0,
            ),
            child: AppIconHeader(
              size: 40.0,
              padding: EdgeInsets.zero,
              onTap: widget.onTapIconHeader,
            ),
          ),
          flexibleSpace: userSection(),
        );
      },
    );
  }

  Widget addNewQuoteButton() {
    return RaisedButton(
      onPressed: () {
        AddQuoteInputs.clearAll();
        AddQuoteInputs.navigatedFromPath = 'dashboard';
        FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      color: stateColors.primary,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.add, color: Colors.white),
          ),

          Text(
            'Propose new quote',
            style: TextStyle(
              color: Colors.white,
              // fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget signupButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FlatButton(
        onPressed: () {
          FluroRouter.router.navigateTo(
            context,
            SignupRoute,
          );
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
        FluroRouter.router.navigateTo(
          context,
          SigninRoute,
        );
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

  Widget userAvatar() {
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

          FluroRouter.router.navigateTo(
            context,
            value,
          );
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem(
            value: FavouritesRoute,
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text(
                'Favourites',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          const PopupMenuItem(
            value: ListsRoute,
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text(
                'Lists',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ),

          const PopupMenuItem(
            value: DraftsRoute,
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Drafts',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: PublishedQuotesRoute,
            child: ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text(
                'Published',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          const PopupMenuItem(
            value: TempQuotesRoute,
            child: ListTile(
              leading: Icon(Icons.timelapse),
              title: Text(
                'In Validation',
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

  Widget userSection() {
    return Observer(builder: (context) {
      final children = List<Widget>();

      if (userState.isUserConnected) {
        children.addAll([
          userAvatar(),
          addNewQuoteButton(),
        ]);

      } else {
        children.addAll([
          signinButton(),
          signupButton()
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
}
