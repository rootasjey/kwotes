import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/components/base_page_app_bar.dart';
import 'package:figstyle/components/circle_button.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/language.dart';

class PageAppBar extends StatefulWidget {
  final bool descending;
  final bool showNavBackIcon;

  final double expandedHeight;
  final double collapsedHeight;
  final double toolbarHeight;

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

  /// App bar's title. Usually a Text widget.
  /// If set, 'textTitle' property will be ignored.
  final Widget title;

  const PageAppBar({
    Key key,
    this.additionalIconButtons = const [],
    this.collapsedHeight,
    this.descending = true,
    this.expandedHeight = 110.0,
    this.itemsLayout = ItemsLayout.list,
    this.lang = '',
    this.onDescendingChanged,
    this.onIconPressed,
    this.onItemsLayoutSelected,
    this.onLangChanged,
    this.onTitlePressed,
    this.showNavBackIcon = true,
    this.textTitle,
    this.textSubTitle,
    this.title,
    this.toolbarHeight,
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
    final showOrderButtons = widget.onDescendingChanged != null;
    final showLangSelector = widget.onLangChanged != null;
    final showItemsLayout = widget.onItemsLayoutSelected != null;

    return BasePageAppBar(
      expandedHeight: widget.expandedHeight,
      title: widget.textSubTitle != null ? twoLinesTitle() : oneLineTitle(),
      showNavBackIcon: widget.showNavBackIcon,
      bottom: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Wrap(
            spacing: 10.0,
            alignment: WrapAlignment.start,
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
          ),
        ),
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
    return Observer(builder: (context) {
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
    });
  }

  Widget oneLineTitle() {
    if (widget.title != null) {
      return widget.title;
    }

    if (widget.showNavBackIcon) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleButton(
              onTap: () {
                Navigator.of(context).pop();
              },
              backgroundColor: stateColors.primary,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          TextButton.icon(
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
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: TextButton.icon(
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          size: 30.0,
          onTap: widget.onIconPressed,
        ),
        Expanded(
          child: InkWell(
            onTap: widget.onTitlePressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.title != null
                    ? widget.title
                    : Text(
                        widget.textTitle,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: stateColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    widget.textSubTitle,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: stateColors.foreground,
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
