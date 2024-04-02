import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/drafts/drafts_page.dart";
import "package:kwotes/screens/in_validation/in_validation_page.dart";
import "package:kwotes/screens/published/published_page.dart";

class MyQuotesPage extends StatefulWidget {
  const MyQuotesPage({super.key});

  @override
  State<MyQuotesPage> createState() => _MyQuotesPageState();
}

class _MyQuotesPageState extends State<MyQuotesPage> {
  final _bodyChildren = [
    const DraftsPage(isInTab: true),
    const InValidationPage(isInTab: true),
    const PublishedPage(isInTab: true),
  ];

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).textTheme.bodyMedium?.color;
    const double iconSize = 16.0;

    return DefaultTabController(
      initialIndex: 0,
      length: _bodyChildren.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 0.0, top: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleButton.outlined(
                  tooltip: "back".tr(),
                  margin: const EdgeInsets.only(right: 12.0),
                  borderColor: Colors.transparent,
                  onTap: () => Utils.passage.back(context),
                  child: Icon(
                    TablerIcons.arrow_left,
                    size: 20.0,
                    color: foregroundColor?.withOpacity(0.8),
                  ),
                ),
                Flexible(
                  child: TabBar(
                    tabAlignment: TabAlignment.center,
                    tabs: <Widget>[
                      Utils.graphic.tooltip(
                        tooltipString: "drafts.name".tr(),
                        child: const Tab(
                          child: Icon(TablerIcons.note, size: iconSize),
                        ),
                      ),
                      Utils.graphic.tooltip(
                        tooltipString: "in_validation.name".tr(),
                        child: const Tab(
                          icon: Icon(TablerIcons.clock, size: iconSize),
                        ),
                      ),
                      Utils.graphic.tooltip(
                        tooltipString: "published.name".tr(),
                        child: const Tab(
                          icon: Icon(TablerIcons.send, size: iconSize),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: _bodyChildren,
        ),
      ),
    );
  }
}
