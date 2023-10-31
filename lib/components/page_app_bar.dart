import "dart:ui";

import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:unicons/unicons.dart";

class PageAppBar extends StatelessWidget {
  const PageAppBar({
    super.key,
    required this.childTitle,
    this.isMobileSize = false,
  });

  /// Adapt the user interface to small screens if true.
  final bool isMobileSize;

  /// Page's title.
  final Widget childTitle;

  @override
  Widget build(BuildContext context) {
    final String location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .uri
        .toString();

    final bool hasHistory = location != HomeLocation.route;

    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
            Colors.black;

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 6.0,
      toolbarHeight: 200.0,
      centerTitle: false,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
      automaticallyImplyLeading: false,
      title: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Padding(
            padding: const EdgeInsets.only(left: 0.0, top: 42.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHistory)
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: CircleButton.outlined(
                      borderColor: Colors.transparent,
                      onTap: () => Utils.passage.back(
                        context,
                        isMobile: isMobileSize,
                      ),
                      child: Icon(
                        UniconsLine.arrow_left,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                childTitle,
              ],
            )),
      ),
      // bottom: bottom,
    );
  }
}
