import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/language.dart';

class PageAppBar extends StatefulWidget {
  final bool descending;
  final bool showNavBackIcon;

  final double expandedHeight;

  final Function(bool) onDescendingChanged;
  final Function(String) onLangChanged;

  final void Function(ItemsLayout) onItemsLayoutSelected;
  final void Function() onIconPressed;
  final void Function() onTitlePressed;

  final ItemsLayout itemsLayout;

  /// Additional custom icon buttons.
  final List<Widget> additionalIconButtons;

  final String textTitle;
  final String textSubTitle;
  final String lang;

  const PageAppBar({
    Key key,
    this.additionalIconButtons = const [],
    this.descending = true,
    this.expandedHeight = 130.0,
    this.itemsLayout = ItemsLayout.list,
    this.lang = '',
    this.onDescendingChanged,
    this.onIconPressed,
    this.onItemsLayoutSelected,
    this.onLangChanged,
    this.onTitlePressed,
    this.showNavBackIcon = true,
    @required this.textTitle,
    this.textSubTitle,
  }) : super(key: key);

  @override
  _PageAppBarState createState() => _PageAppBarState();
}

class _PageAppBarState extends State<PageAppBar> {
  @override
  initState() {
    super.initState();

    if (widget.onLangChanged != null &&
        (widget.lang == null || widget.lang.isEmpty)) {
      debugPrint("Please specify a value for the 'lang' property.");
    }

    if (widget.onItemsLayoutSelected != null && widget.itemsLayout == null) {
      debugPrint("Please specify a value for the 'itemsLayout' property.");
    }

    if (widget.onDescendingChanged != null && widget.descending == null) {
      debugPrint("Please specify a value for the 'descending' property.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double leftSubHeaderPadding = 165.0;

    if (width < 700.0) {
      leftSubHeaderPadding = 50.0;
    }
    if (width < 390.0) {
      leftSubHeaderPadding = 30.0;
    }

    return BasePageAppBar(
      expandedHeight: widget.expandedHeight,
      title: widget.textSubTitle != null ? twoLinesTitle() : oneLineTitle(),
      titlePadding: width < 390.0 ? EdgeInsets.only(left: 20.0) : null,
      showNavBackIcon: widget.showNavBackIcon,
      subHeaderPadding: EdgeInsets.only(
        left: leftSubHeaderPadding,
      ),
      subHeader: Observer(
        builder: (context) {
          final showOrderButtons = widget.onDescendingChanged != null;
          final showLangSelector = widget.onLangChanged != null;
          final showItemsLayout = widget.onItemsLayoutSelected != null;

          return Wrap(
            spacing: 10.0,
            children: <Widget>[
              if (showOrderButtons) orderButton(),
              if (showOrderButtons && showLangSelector)
                separator(), // separator
              if (showLangSelector) langSelector(),
              if (showLangSelector && showItemsLayout) separator(), // separator
              if (showOrderButtons && showItemsLayout && !showLangSelector)
                separator(), // separator
              if (showItemsLayout) itemsLayoutSelector(),
              ...widget.additionalIconButtons,
            ],
          );
        },
      ),
    );
  }

  Widget itemsLayoutSelector() {
    return DropdownButton<ItemsLayout>(
      icon: Container(),
      underline: Container(),
      value: widget.itemsLayout,
      onChanged: (itemsLayout) {
        widget.onItemsLayoutSelected(itemsLayout);
      },
      items: [
        DropdownMenuItem(
          value: ItemsLayout.list,
          child: Opacity(
            opacity: 0.6,
            child: Icon(Icons.list),
          ),
        ),
        DropdownMenuItem(
          value: ItemsLayout.grid,
          child: Opacity(
            opacity: 0.6,
            child: Icon(Icons.grid_on),
          ),
        ),
      ],
    );
  }

  Widget langSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: DropdownButton<String>(
        elevation: 2,
        value: widget.lang,
        isDense: true,
        underline: Container(),
        icon: Container(),
        style: TextStyle(
          color: stateColors.foreground.withOpacity(0.6),
          fontSize: 20.0,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        onChanged: widget.onLangChanged,
        items: Language.available().map((String value) {
          return DropdownMenuItem(
              value: value,
              child: Text(
                value.toUpperCase(),
              ));
        }).toList(),
      ),
    );
  }

  Widget oneLineTitle() {
    return TextButton.icon(
      onPressed: widget.onTitlePressed,
      icon: AppIcon(
        padding: EdgeInsets.zero,
        size: 30.0,
      ),
      label: Text(
        widget.textTitle,
        style: TextStyle(
          fontSize: 22.0,
        ),
      ),
    );
  }

  Widget orderButton() {
    final descending = widget.descending;

    return DropdownButton<bool>(
      value: descending,
      icon: Container(),
      underline: Container(),
      onChanged: (newDescending) {
        widget.onDescendingChanged(newDescending);
      },
      items: [
        DropdownMenuItem(
          child: Opacity(
              opacity: 0.6, child: FaIcon(FontAwesomeIcons.sortNumericDownAlt)),
          value: true,
        ),
        DropdownMenuItem(
          child: Opacity(
              opacity: 0.6, child: FaIcon(FontAwesomeIcons.sortNumericUpAlt)),
          value: false,
        ),
      ],
    );
  }

  Widget separator() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 20.0,
      ),
      child: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: stateColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget twoLinesTitle() {
    return Row(
      children: [
        CircleButton(
            onTap: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: stateColors.foreground)),
        AppIcon(
          padding: EdgeInsets.zero,
          size: 30.0,
          onTap: widget.onIconPressed,
        ),
        Expanded(
          child: InkWell(
            onTap: widget.onTitlePressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.textTitle,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    widget.textSubTitle,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
