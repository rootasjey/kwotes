import 'package:auto_route/auto_route.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/types/side_menu_item.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sideMenuItems = <SideMenuItem>[
    SideMenuItem(
      destination: FavouritesRoute(),
      iconData: UniconsLine.heart,
      label: 'Favourites',
      hoverColor: Colors.red,
    ),
    SideMenuItem(
      destination: QuotesListsDeepRoute(),
      iconData: UniconsLine.list_ul,
      label: 'Lists',
      hoverColor: Colors.blue.shade700,
    ),
    SideMenuItem(
      destination: DraftsRoute(),
      iconData: UniconsLine.edit,
      label: 'Drafts',
      hoverColor: Colors.pink.shade200,
    ),
    SideMenuItem(
      destination: MyPublishedQuotesRoute(),
      iconData: UniconsLine.cloud_upload,
      label: 'My Published',
      hoverColor: Colors.green,
    ),
    SideMenuItem(
      destination: MyTempQuotesRoute(),
      iconData: UniconsLine.clock,
      label: 'My Temporary',
      hoverColor: Colors.yellow.shade800,
    ),
    SideMenuItem(
      destination: DashboardSettingsDeepRoute(
        children: [DashboardSettingsRoute()],
      ),
      iconData: UniconsLine.setting,
      label: 'Settings',
      hoverColor: Colors.blueGrey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    tryAddAdminPage();
  }

  @override
  Widget build(context) {
    return AutoRouter(
      builder: (context, child) {
        return Material(
          child: Row(
            children: [
              buildSideMenu(context),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget buildSideMenu(BuildContext context) {
    final router = context.router;

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return Container();
    }

    return Container(
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      width: 300.0,
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 50.0,
                ),
                sliver: DesktopAppBar(
                  showAppIcon: false,
                  automaticallyImplyLeading: false,
                  leftPaddingFirstDropdown: 0,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(
                  _sideMenuItems.map((item) {
                    Color color = stateColors.foreground.withOpacity(0.6);
                    Color textColor = stateColors.foreground.withOpacity(0.6);

                    if (item.destination.fullPath ==
                        router.current?.route?.fullPath) {
                      color = item.hoverColor;
                      textColor = stateColors.foreground;
                    }

                    return ListTile(
                      leading: Icon(
                        item.iconData,
                        color: color,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      onTap: () {
                        if (item.destination.routeName == 'AdminDeepRoute') {
                          item.destination.show(context);
                          return;
                        }

                        router.navigate(item.destination);
                      },
                    );
                  }).toList(),
                )),
              ),
            ],
          ),
          Positioned(
            left: 40.0,
            bottom: 20.0,
            child: RaisedButton(
              onPressed: () {
                DataQuoteInputs.clearAll();
                router.navigate(AddQuoteStepsRoute());
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              color: stateColors.accent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 160.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(UniconsLine.plus, color: Colors.white),
                      Padding(padding: const EdgeInsets.only(left: 10.0)),
                      Text(
                        'Add quote',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void tryAddAdminPage() async {
    if (!stateUser.canManageQuotes) {
      return;
    }

    _sideMenuItems.addAll([
      SideMenuItem(
        destination: AdminDeepRoute(
          children: [
            AdminTempDeepRoute(
              children: [
                AdminTempQuotesRoute(),
              ],
            )
          ],
        ),
        iconData: UniconsLine.clock_two,
        label: 'Admin Temp Quotes',
        hoverColor: Colors.red,
      ),
      SideMenuItem(
        destination: AdminDeepRoute(children: [QuotidiansRoute()]),
        iconData: UniconsLine.sunset,
        label: 'Quotidians',
        hoverColor: Colors.red,
      ),
    ]);
  }
}
