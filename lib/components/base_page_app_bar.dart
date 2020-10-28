import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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

  /// If set, will be shown at the bottom of the title.
  final Widget subHeader;

  /// App bar title.
  final String textTitle;

  /// Will override [textTitle] if set.
  final Widget title;

  BasePageAppBar({
    this.toolbarHeight = kToolbarHeight,
    this.collapsedHeight,
    this.expandedHeight = 210.0,
    this.onPressedMenu,
    this.pinned = false,
    this.showNavBackIcon = true,
    this.subHeader,
    this.textTitle,
    this.title,
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

        if (constrains.maxWidth < 700.0) {
          titleFontSize = 25.0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            headerSection(titleFontSize),
            subHeaderSection(),
          ],
        );
      },
    );
  }

  Widget headerSection(double titleFontSize) {
    return widget.title != null
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
          );
  }

  Widget subHeaderSection() {
    if (widget.subHeader == null) {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }

    return widget.subHeader;
  }
}
