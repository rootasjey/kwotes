import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/types/changelog_item.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Changelog extends StatefulWidget {
  @override
  _ChangelogState createState() => _ChangelogState();
}

class _ChangelogState extends State<Changelog> {
  List<ChangelogItem> changelogItemsList = [];

  @override
  void initState() {
    super.initState();
    initContent();
  }

  initContent() {
    changelogItemsList.addAll([
      itemChangelogTemplate(
        textTitle: "2.0.0",
        date: DateTime(2020, 12, 01),
        children: [
          descriptionRow("• Re-design add quote experience"),
          descriptionRow("• Fix push notifications"),
          descriptionRow("• Add share image quote"),
          descriptionRow("• Update quote page & other pages layout"),
          descriptionRow("• Add search by quotes, authors, references"),
          descriptionRow("• Add changelog"),
          descriptionRow("• Add swipe actions on quote tiles"),
          descriptionRow("• Re-work application icon"),
          descriptionRow("• Add onboarding"),
          descriptionRow("• Update first app's page"),
          descriptionRow("• Use better image preview"),
          descriptionRow("• Bug fixes and other improvements"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.3.0",
        date: DateTime(2020, 07, 22),
        children: [
          descriptionRow(
              "• Minor UI update: add a top right close button on quotidian page"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.2.3",
        date: DateTime(2020, 07, 08),
        children: [
          descriptionRow(
              "• Fix an issue where a draft without topics wouldn't show"),
          descriptionRow("• Speed up topics animation on add quote page"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.2.1",
        date: DateTime(2020, 06, 17),
        children: [
          descriptionRow(
              "• Fix a visual bug where link cards on author page would have a longer height than expected"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "1.2.0",
        date: DateTime(2020, 06, 15),
        children: [
          descriptionRow("• Add help center link"),
          descriptionRow("• Update design"),
          descriptionRow("• Add inputs format checks for username & email"),
          descriptionRow("• Add availability checks for email & username"),
          descriptionRow("• Better error messages"),
          descriptionRow("• Bug fixes"),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool showUserMenu = true;
    double horPadding = 80.0;

    if (width < Constants.maxMobileWidth) {
      showUserMenu = false;
      horPadding = 20.0;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DesktopAppBar(
            title: "Changelog",
            automaticallyImplyLeading: true,
            showUserMenu: showUserMenu,
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
              vertical: 60.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "You can find the app version history below",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      changelogItemsList[index].isExpanded = !isExpanded;
                    });
                  },
                  children: changelogItemsList.map((changelogItem) {
                    final date = changelogItem.date;
                    final day = date.day < 10 ? '0${date.day}' : date.day;
                    final month =
                        date.month < 10 ? '0${date.month}' : date.month;

                    return ExpansionPanel(
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: changelogItem.title,
                          subtitle: Text("$day/$month/${date.year}"),
                          onTap: () {
                            setState(
                              () {
                                changelogItem.isExpanded =
                                    !changelogItem.isExpanded;
                              },
                            );
                          },
                        );
                      },
                      isExpanded: changelogItem.isExpanded,
                      body: changelogItem.child,
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: InkWell(
                      onTap: () => launch(
                          "https://github.com/rootasjey/fig.style/releases"),
                      child: Text(
                        "See releases online",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget descriptionRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  ChangelogItem itemChangelogTemplate({
    @required DateTime date,
    @required String textTitle,
    List<Widget> children = const <Widget>[],
  }) {
    return ChangelogItem(
      title: Text(
        textTitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      date: date,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
