import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/discover.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_quotidian.dart';
import 'package:memorare/components/web/home_app_bar.dart';
import 'package:memorare/components/web/topics.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:supercharged/supercharged.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Observer(
        builder: (context) {
          if (userState.isUserConnected) {
            return FloatingActionButton.extended(
              onPressed: () {
                AddQuoteInputs.clearAll();
                AddQuoteInputs.navigatedFromPath = 'dashboard';
                FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
              },
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              icon: Icon(Icons.add),
              label: Text('Propose new quote'),
            );
          }

          return Padding(padding: EdgeInsets.zero,);
        }
      ),
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          HomeAppBar(
            onTapIconHeader: () {
              scrollController.animateTo(
                0,
                duration: 250.milliseconds,
                curve: Curves.decelerate,
              );
            },
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              FullPageQuotidian(),
              Topics(),
              Discover(),
              Footer(pageScrollController: scrollController,),
            ]),
          ),
        ],
      ),
    );
  }
}
