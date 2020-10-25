import 'package:flutter/material.dart';
import 'package:figstyle/components/discover_references.dart';
import 'package:figstyle/components/discover_authors.dart';
import 'package:figstyle/components/footer.dart';
import 'package:figstyle/components/quotidian_page.dart';
import 'package:figstyle/components/main_app_bar.dart';
import 'package:figstyle/components/topics.dart';
import 'package:supercharged/supercharged.dart';

class HomeDesktop extends StatefulWidget {
  @override
  _HomeDesktopState createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          MainAppBar(
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
              QuotidianPage(),
              Topics(),
              DiscoverReferences(),
              DiscoverAuthors(),
              Footer(
                pageScrollController: scrollController,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
