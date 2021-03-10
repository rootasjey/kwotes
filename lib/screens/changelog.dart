import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/changelog_item.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
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
        textTitle: Constants.appVersion,
        date: DateTime(2021, 03, 11),
        children: [
          descriptionRow(
              "• Add image credits input for author & reference images"),
          descriptionRow("• Add IMDB field for author & reference"),
          descriptionRow("• Fix an issue preventing to go back"
              " from 'add quote' page with keys shortcuts"),
          descriptionRow("• Upgrade Flutter engine to 2.0.1"
              " and dependencies"),
          descriptionRow("• Other fixes & improvements"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "2.68.7",
        date: DateTime(2021, 02, 26),
        children: [
          descriptionRow("• Fix multiple date conversion issues"),
          descriptionRow("• Update link cards style (e.g. on author page)"),
          descriptionRow(
              "• Fix author image link input keeping last (other input) value"),
          descriptionRow("• Fix author navigation from reference page"),
          descriptionRow("• Fix nav. back icon clipped on PageAppBar"),
          descriptionRow("• Fix app bar overflow sometimes"),
          descriptionRow("• Fix icons alignment on app bar"),
          descriptionRow("• Reduce top padding on topic page"),
          descriptionRow(
              "• Add a close button on side bar, at the top, on topic page"),
          descriptionRow(
              "• Show author's name on quote card (when available) (grid layout)"),
          descriptionRow("• Update font on quote card (grid layout)"),
          descriptionRow("• Add release date on reference page"),
          descriptionRow("• Fix navigation (from quote page) to topic page"),
          descriptionRow("• Update Firebase dependencies"),
          descriptionRow("• Update types layout on reference page"),
          descriptionRow("• Update data schemes (for database compatibility)"),
          descriptionRow("• Add visual feedback when saving draft"),
          descriptionRow("• Update random quotes page for mobile"),
        ],
      ),
      itemChangelogTemplate(
        textTitle: "2.47.1",
        date: DateTime(2021, 02, 22),
        children: [
          descriptionRow(
              "• Add random quotes (replace topics section on mobile)"),
          descriptionRow("• Fix an issue preventing deleting drafts"),
          descriptionRow("• Improve key binding for add quote desktop layout"),
          descriptionRow("• Improve 'add quote' page layout"),
          descriptionRow("• Improve quote page layout on mobile"),
          descriptionRow("• Improve lists management"),
          descriptionRow("• Fix missing email & username on settings page"),
          descriptionRow(
              "• Fix bottom sheet not dismissed after selecting add quote to list"),
          descriptionRow("• Fix on boarding sign in scenario"),
          descriptionRow("• On boarding message is now more discrete"),
          descriptionRow("• Use new snack bar layout"),
          descriptionRow("• Use new cloud function to propose quotes"),
          descriptionRow(
              "• Add quotes, authors, references deletion and edition"),
          descriptionRow("• Fix language dropdown on various pages"),
          descriptionRow("• Add a button to shuffle accent color"),
          descriptionRow("• Update data schemes (for database compatibility)"),
          descriptionRow(
              "• Add swipe action on desktop layout for quote row item"),
          descriptionRow("• Update some texts and fix typos"),
          descriptionRow(
              "• Increase maximum quotes proposals per day (from 1 to 30)"),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double horPadding = 80.0;
    double vertPadding = 60.0;

    if (width < Constants.maxMobileWidth) {
      horPadding = 20.0;
      vertPadding = 12.0;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          appBar(),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: horPadding,
              vertical: vertPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                titleContainer(),
                subtitleContainer(),
                expansionPanList(),
                onlineReleasesButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return PageAppBar(textTitle: "App versions");
    }

    return DesktopAppBar();
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
          fontSize: 18.0,
          color: stateColors.secondary,
          fontWeight: FontWeight.w700,
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

  Widget expansionPanList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 600.0,
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                changelogItemsList[index].isExpanded = !isExpanded;
              });
            },
            children: changelogItemsList.map((changelogItem) {
              final date = changelogItem.date;
              final day = date.day < 10 ? '0${date.day}' : date.day;
              final month = date.month < 10 ? '0${date.month}' : date.month;

              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: changelogItem.title,
                    subtitle: Opacity(
                      opacity: 0.5,
                      child: Text("$day/$month/${date.year}"),
                    ),
                    onTap: () {
                      setState(
                        () {
                          changelogItem.isExpanded = !changelogItem.isExpanded;
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
        ),
      ],
    );
  }

  Widget onlineReleasesButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Opacity(
          opacity: 0.6,
          child: InkWell(
            onTap: () =>
                launch("https://github.com/rootasjey/fig.style/releases"),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 20.0,
                children: [
                  Text(
                    "See more releases online",
                    style: TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(
                    UniconsLine.external_link_alt,
                    size: 18.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget subtitleContainer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Opacity(
        opacity: 0.4,
        child: Text(
          "You can find the app version history below",
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget titleContainer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          "Changelog",
          style: TextStyle(
            fontSize: 60.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
