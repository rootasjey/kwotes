import 'package:auto_route/auto_route.dart';
import 'package:fig_style/components/desktop_app_bar.dart';
import 'package:fig_style/router/app_router.gr.dart';
import 'package:fig_style/state/colors.dart';
import 'package:flutter/material.dart';

class UndefinedPage extends StatefulWidget {
  @override
  _UndefinedPageState createState() => _UndefinedPageState();
}

class _UndefinedPageState extends State<UndefinedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DesktopAppBar(),
          SliverPadding(
            padding: const EdgeInsets.only(top: 60.0),
            sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
              Column(
                children: <Widget>[
                  title(),
                  subtitle(),
                  navButton(),
                  illustration(),
                  quoteCard(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 300.0),
                  ),
                ],
              ),
            ])),
          )
        ],
      ),
    );
  }

  Widget quoteCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 500.0,
        child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      // 'It is by getting lost that we learn.',
                      'When we are lost, what matters is to find our way back.',
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100.0,
                    child: Divider(
                      height: 50.0,
                      thickness: 1.0,
                    ),
                  ),
                  Opacity(
                    opacity: 0.6,
                    child: Text('fig.style'),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget illustration() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50.0,
        bottom: 80.0,
      ),
      child: Image(
        image: AssetImage('assets/images/olha_khomich/not_found.png'),
        width: 350.0,
        height: 350.0,
      ),
    );
  }

  Widget navButton() {
    return TextButton.icon(
      onPressed: () => context.router.navigate(HomeRoute()),
      icon: Icon(Icons.arrow_back),
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Return on the way'),
      ),
    );
  }

  Widget subtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Opacity(
        opacity: 0.6,
        child: RichText(
          text: TextSpan(
            text: 'Route for ',
            style: TextStyle(
              fontSize: 18.0,
              color: stateColors.foreground,
            ),
            children: [
              TextSpan(
                text: '${context.route.match}',
                style: TextStyle(
                  color: stateColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' is not defined.',
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      '404',
      style: TextStyle(
        fontSize: 120.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
