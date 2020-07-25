import 'package:flutter/material.dart';
import 'package:memorare/components/ColoredListTile.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';

class DashboardSectionTemplate extends StatefulWidget {
  final Widget child;
  final String childName;

  DashboardSectionTemplate({
    this.child,
    this.childName = '',
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
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: stateColors.primary,
                        // backgroundImage: AssetImage(
                        //   userState.avatarUrl,
                        // ),
                        radius: 20.0,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        userState.username,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.keyboard_arrow_down),
                        tooltip: 'More quick links',
                        onSelected: (value) {
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
                            value: 'dashboard',
                            child: ListTile(
                              leading: Icon(Icons.dashboard),
                              title: Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),

                    Padding(padding: const EdgeInsets.only(bottom: 100.0)),

                    ColoredListTile(
                      icon: Icons.list,
                      outlined: false,
                      hoverColor: Colors.blue.shade700,
                      title: Text(
                        'Lists',
                      ),
                      onTap: () {},
                    ),

                    ColoredListTile(
                      icon: Icons.favorite,
                      outlined: false,
                      selected: widget.childName == 'favourites',
                      hoverColor: Colors.red,
                      title: Text(
                        'Favourites',

                      ),
                      onTap: () {},
                    ),

                    ColoredListTile(
                      icon: Icons.edit,
                      outlined: false,
                      hoverColor: Colors.purple.shade300,
                      title: Text(
                        'Drafts',
                      ),
                      onTap: () {},
                    ),

                    ColoredListTile(
                      icon: Icons.cloud_done,
                      outlined: false,
                      hoverColor: Colors.green,
                      title: Text(
                        'Published',
                      ),
                      onTap: () {},
                    ),

                    ColoredListTile(
                      icon: Icons.timelapse,
                      outlined: false,
                      hoverColor: Colors.lightBlue.shade900,
                      title: Text(
                        'In Validation',

                      ),
                      onTap: () {},
                    ),

                    Padding(padding: const EdgeInsets.only(bottom: 100.0),),
                  ],
                ),

                  Positioned(
                    left: 20.0,
                    bottom: 20.0,
                    child: RaisedButton(
                      onPressed: () {
                        AddQuoteInputs.clearAll();
                        AddQuoteInputs.navigatedFromPath = 'dashboard';
                        FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.add),
                            Padding(padding: const EdgeInsets.only(left: 10.0),),
                            Text('Propose new quote'),
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
