import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:figstyle/components/colored_list_tile.dart';
import 'package:figstyle/components/side_bar_header.dart';
import 'package:figstyle/components/data_quote_inputs.dart';
import 'package:figstyle/router/route_names.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';

import 'add_quote/steps.dart';

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
  _DashboardSectionTemplateState createState() =>
      _DashboardSectionTemplateState();
}

class _DashboardSectionTemplateState extends State<DashboardSectionTemplate> {
  ///  Current State of InnerDrawerState
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  /// The authenticated user can manage quotes if true.
  static bool isAdmin = false;

  @override
  initState() {
    super.initState();
    checkAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = MediaQuery.of(context).size.width;

        return screenWidth < 1000.0 ? smallView() : wideView();
      },
    );
  }

  Widget wideView() {
    return Material(
      child: Row(
        children: <Widget>[
          Expanded(
            child: sideBarContent(),
          ),
          Expanded(
            flex: 3,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  List<Widget> adminTiles() {
    return [
      Divider(
        thickness: 1.0,
        height: 20.0,
      ),
      ColoredListTile(
        icon: Icons.cloud,
        outlined: false,
        hoverColor: Colors.green.shade200,
        selected: widget.childName == RouteNames.QuotesRoute,
        title: Text(
          'All Published quotes',
        ),
        onTap: () => navigateToSection(RouteNames.QuotesRoute),
      ),
      ColoredListTile(
        icon: Icons.timelapse,
        outlined: false,
        hoverColor: Colors.orange.shade200,
        selected: widget.childName == RouteNames.AdminTempQuotesRoute,
        title: Text(
          'All In Validation',
        ),
        onTap: () => navigateToSection(RouteNames.AdminTempQuotesRoute),
      ),
      ColoredListTile(
        icon: Icons.wb_sunny,
        outlined: false,
        hoverColor: Colors.yellow.shade600,
        selected: widget.childName == RouteNames.QuotidiansRoute,
        title: Text(
          'Quotidians',
        ),
        onTap: () => navigateToSection(RouteNames.QuotidiansRoute),
      ),
    ];
  }

  Widget sideBarContent() {
    return Container(
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 50.0,
                ),
                child: SideBarHeader(),
              ),
              ColoredListTile(
                icon: Icons.favorite,
                outlined: false,
                selected: widget.childName == RouteNames.FavouritesRoute,
                hoverColor: Colors.red,
                title: Text(
                  'Favourites',
                ),
                onTap: () => navigateToSection(RouteNames.FavouritesRoute),
              ),
              ColoredListTile(
                icon: Icons.list,
                outlined: false,
                hoverColor: Colors.blue.shade700,
                selected: widget.childName == RouteNames.ListsRoute,
                title: Text(
                  'Lists',
                ),
                onTap: () => navigateToSection(RouteNames.ListsRoute),
              ),
              ColoredListTile(
                icon: Icons.edit,
                outlined: false,
                hoverColor: Colors.pink.shade200,
                selected: widget.childName == RouteNames.DraftsRoute,
                title: Text(
                  'Drafts',
                ),
                onTap: () => navigateToSection(RouteNames.DraftsRoute),
              ),
              ColoredListTile(
                icon: Icons.cloud_done,
                outlined: false,
                hoverColor: Colors.green,
                selected: widget.childName == RouteNames.PublishedQuotesRoute,
                title: Text(
                  'Published',
                ),
                onTap: () => navigateToSection(RouteNames.PublishedQuotesRoute),
              ),
              ColoredListTile(
                icon: Icons.timelapse,
                outlined: false,
                hoverColor: Colors.yellow.shade800,
                selected: widget.childName == RouteNames.TempQuotesRoute,
                title: Text(
                  'In Validation',
                ),
                onTap: () => navigateToSection(RouteNames.TempQuotesRoute),
              ),
              if (isAdmin) ...adminTiles(),
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
              ),
            ],
          ),
          Positioned(
            left: 15.0,
            bottom: 20.0,
            child: RaisedButton(
              onPressed: () {
                DataQuoteInputs.clearAll();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => AddQuoteSteps()));
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              color: stateColors.primary,
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

  void navigateToSection(String route) {
    if (widget.childName == route && !widget.isNested) {
      return;
    }

    // Rerouter.push(context: context, value: route);
  }

  Widget smallView() {
    return InnerDrawer(
      key: _innerDrawerKey,
      tapScaffoldEnabled: true,
      offset: IDOffset.only(
        left: 0.0,
      ),
      leftChild: Material(
        child: sideBarContent(),
      ),
      scaffold: widget.child,
    );
  }

  void checkAdmin() async {
    try {
      final userAuth = stateUser.userAuth;

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      if (!user.exists) {
        return;
      }

      setState(() {
        isAdmin = user.data()['rights']['user:managequote'] == true;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
