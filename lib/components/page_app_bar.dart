import "dart:ui";

import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/home_location.dart";

class PageAppBar extends StatelessWidget {
  const PageAppBar({
    super.key,
    this.axis = Axis.vertical,
    this.isMobileSize = false,
    this.toolbarHeight = 200.0,
    this.children = const [],
    this.hideBackButton = false,
    this.backgroundColor,
  });

  /// Page's axis.
  final Axis axis;

  /// Hide back button if true.
  final bool hideBackButton;

  /// Adapt the user interface to small screens if true.
  final bool isMobileSize;

  /// App bar's background color.
  final Color? backgroundColor;

  /// App bar's toolbar height.
  final double toolbarHeight;

  // /// Page's title children.
  final List<Widget> children;

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

    final List<Widget> childrenLayout = [
      if (hasHistory && !hideBackButton)
        CircleButton.outlined(
          borderColor: Colors.transparent,
          onTap: () => Utils.passage.back(
            context,
            isMobile: isMobileSize,
          ),
          child: Icon(
            TablerIcons.arrow_left,
            color: foregroundColor,
          ),
        ),
      ...children,
    ];

    final Flex layoutChild = axis == Axis.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childrenLayout,
          )
        : Row(children: childrenLayout);

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 6.0,
      toolbarHeight: toolbarHeight,
      centerTitle: false,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      title: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Padding(
          padding: isMobileSize
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 28.0, top: 42.0),
          child: layoutChild,
        ),
      ),
    );
  }
}
