import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/discover.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_quotidian.dart';
import 'package:memorare/components/web/previous_quotidians.dart';
import 'package:memorare/components/web/top_bar.dart';
import 'package:memorare/components/web/topics.dart';
import 'package:memorare/state/user_connection.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Observer(
        builder: (context) {
          if (isUserConnected.value) {
            return FloatingActionButton.extended(
              onPressed: () {
                FluroRouter.router.navigateTo(context, DashboardRoute);
              },
              icon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
              backgroundColor: Colors.pink,
            );
          }

          return Padding(padding: EdgeInsets.zero,);
        }
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          TopBar(),
          FullPageQuotidian(),
          PreviousQuotidians(),
          Topics(),
          Discover(),
          Footer(pageScrollController: _scrollController,),
        ],
      ),
    );
  }
}
