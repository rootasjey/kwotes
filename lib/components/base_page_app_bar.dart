import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/state/colors.dart';

class BasePageAppBar extends StatefulWidget {
  // Appbar's height.
  final double expandedHeight;

  /// Typically open a drawer. Menu icon will be hidden if null.
  final Function onPressedMenu;

  /// If true, the back icon will be visible.
  final bool showNavBackIcon;

  /// If set, will be shown at the bottom of the title.
  final Widget subHeader;

  /// App bar title.
  final String textTitle;

  /// Will override [textTitle] if set.
  final Widget title;

  /// Distance between the top of the screen and the title.
  final double topTitleSpacing;

  BasePageAppBar({
    this.showNavBackIcon = true,
    this.onPressedMenu,
    this.subHeader,
    this.textTitle,
    this.title,
    this.expandedHeight = 210.0,
    this.topTitleSpacing = 20.0,
  });

  @override
  _BasePageAppBarState createState() => _BasePageAppBarState();
}

class _BasePageAppBarState extends State<BasePageAppBar> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          expandedHeight: widget.expandedHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: customFlexibleSpace(),
        );
      },
    );
  }

  Widget customFlexibleSpace() {
    return LayoutBuilder(
      builder: (context, constrains) {
        double titleFontSize = 40.0;
        double leftTitlePadding = 80.0;
        double leftSubHeaderPadding = 165.0;
        double menuIconLeftPadding = 80.0;

        if (constrains.maxWidth < 700.0) {
          titleFontSize = 25.0;
          leftTitlePadding = 40.0;
          leftSubHeaderPadding = 85.0;
          menuIconLeftPadding = 20.0;
        }

        if (!widget.showNavBackIcon) {
          leftSubHeaderPadding -= 40.0;
        }

        return Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headerSection(leftTitlePadding, titleFontSize),
              subHeaderSection(leftSubHeaderPadding),
            ],
          ),
          menuButton(menuIconLeftPadding),
        ]);
      },
    );
  }

  Widget headerSection(double leftTitlePadding, double titleFontSize) {
    return FadeInY(
      delay: 1.0,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftTitlePadding,
          top: widget.topTitleSpacing,
        ),
        child: widget.title != null
            ? widget.title
            : Row(
                children: <Widget>[
                  if (widget.showNavBackIcon) ...[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Back',
                      icon: Icon(Icons.arrow_back),
                    ),
                    Padding(padding: const EdgeInsets.only(right: 45.0)),
                  ],
                  Text(
                    widget.textTitle,
                    style: TextStyle(
                      fontSize: titleFontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget menuButton(double menuIconLeftPadding) {
    if (widget.onPressedMenu == null) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return Positioned(
      top: 107.0,
      left: menuIconLeftPadding,
      child: FadeInY(
        delay: 1.4,
        beginY: 50.0,
        child: IconButton(
          onPressed: widget.onPressedMenu,
          tooltip: 'menu',
          color: stateColors.foreground.withOpacity(0.5),
          icon: Icon(Icons.menu),
        ),
      ),
    );
  }

  Widget subHeaderSection(double leftSubHeaderPadding) {
    if (widget.subHeader == null) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return FadeInY(
      delay: 1.2,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftSubHeaderPadding,
          right: leftSubHeaderPadding,
        ),
        child: widget.subHeader,
      ),
    );
  }
}
