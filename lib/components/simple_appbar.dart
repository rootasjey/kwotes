import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/state/colors.dart';

class SimpleAppBar extends StatefulWidget {
  /// If set, will be shown at the bottom of the title.
  final Widget subHeader;

  /// App bar title.
  final String textTitle;

  /// Will override [textTitle] if set.
  final Widget title;

  /// Typically open a drawer. Menu icon will be hidden if null.
  final Function onPressedMenu;

  /// If true, the back icon will be hidden.
  final bool hideNavBackIcon;

  SimpleAppBar({
    this.hideNavBackIcon = false,
    this.onPressedMenu,
    this.subHeader,
    this.textTitle,
    this.title,
  });

  @override
  _SimpleAppBarState createState() => _SimpleAppBarState();
}

class _SimpleAppBarState extends State<SimpleAppBar> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: stateColors.appBackground.withOpacity(1.0),
          expandedHeight: 210.0,
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

        if (constrains.maxWidth < 600.0) {
          titleFontSize = 25.0;
          leftTitlePadding = 20.0;
          leftSubHeaderPadding = 105.0;
          menuIconLeftPadding = 20.0;
        }

        if (widget.hideNavBackIcon) {
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
          top: 60.0,
        ),
        child: Row(
          children: <Widget>[
            if (!widget.hideNavBackIcon)
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Back',
                icon: Icon(Icons.arrow_back),
              ),
            Padding(padding: const EdgeInsets.only(right: 40.0)),
            widget.title != null
                ? widget.title
                : Text(
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
        ),
        child: widget.subHeader,
      ),
    );
  }
}
