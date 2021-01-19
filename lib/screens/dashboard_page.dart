import 'package:auto_route/auto_route.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/side_menu_item.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sideMenuItems = <SideMenuItem>[
    SideMenuItem(
      destination: FavouritesRoute(),
      iconData: Icons.favorite,
      label: 'Favourites',
      hoverColor: Colors.red,
    ),
    SideMenuItem(
      destination: QuotesListsDeepRoute(),
      iconData: Icons.list,
      label: 'Lists',
      hoverColor: Colors.blue.shade700,
    ),
    SideMenuItem(
      destination: DraftsRoute(),
      iconData: Icons.edit,
      label: 'Drafts',
      hoverColor: Colors.pink.shade200,
    ),
    SideMenuItem(
      destination: MyPublishedQuotesRoute(),
      iconData: Icons.publish_outlined,
      label: 'My Published',
      hoverColor: Colors.green,
    ),
    SideMenuItem(
      destination: MyTempQuotesRoute(),
      iconData: Icons.timelapse,
      label: 'My Temporary',
      hoverColor: Colors.yellow.shade800,
    ),
  ];

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

                    if (item.destination.routeName == router.current?.name) {
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
                      onTap: () => router.navigate(item.destination),
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
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                      ),
                      Text(
                        'New quote',
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
}
