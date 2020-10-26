import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/state/colors.dart';

class BasePageAppBar extends StatefulWidget {
  // Appbar's expanded height.
  final double expandedHeight;
  // Appbar's collapsed height.
  final double collapsedHeight;
  // Appbar's  height.
  final double toolbarHeight;

  /// Typically open a drawer. Menu icon will be hidden if null.
  final Function onPressedMenu;

  final bool pinned;

  /// If true, the back icon will be visible.
  final bool showNavBackIcon;

  final EdgeInsets titlePadding;
  final EdgeInsets subHeaderPadding;

  /// If set, will be shown at the bottom of the title.
  final Widget subHeader;

  /// App bar title.
  final String textTitle;

  /// Will override [textTitle] if set.
  final Widget title;

  /// Distance between the top of the screen and the title.
  final double topTitleSpacing;

  BasePageAppBar({
    this.toolbarHeight = kToolbarHeight,
    this.subHeaderPadding = const EdgeInsets.only(left: 165.0),
    this.collapsedHeight,
    this.expandedHeight = 210.0,
    this.onPressedMenu,
    this.pinned = false,
    this.showNavBackIcon = true,
    this.subHeader,
    this.textTitle,
    this.title,
    this.titlePadding,
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
          pinned: widget.pinned,
          toolbarHeight: widget.toolbarHeight,
          collapsedHeight: widget.collapsedHeight,
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

        if (constrains.maxWidth < 700.0) {
          titleFontSize = 25.0;
          leftTitlePadding = 40.0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            headerSection(leftTitlePadding, titleFontSize),
            subHeaderSection(),
          ],
        );
      },
    );
  }

  Widget headerSection(double leftTitlePadding, double titleFontSize) {
    return FadeInY(
      delay: 1.0,
      beginY: 50.0,
      child: Padding(
        padding: widget.titlePadding != null
            ? widget.titlePadding
            : EdgeInsets.only(
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

  Widget subHeaderSection() {
    if (widget.subHeader == null) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return FadeInY(
      delay: 1.2,
      beginY: 50.0,
      child: Padding(
        padding: widget.subHeaderPadding,
        child: widget.subHeader,
      ),
    );
  }
}
