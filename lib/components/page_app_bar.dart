import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
              if (showOrderButtons) ...orderButtons(),
              if (showOrderButtons && showLangSelector)
                separator(delay: 0.3), // separator
              if (showLangSelector) langSelector(),
              if (showLangSelector && showItemsLayout)
                separator(delay: 0.6), // separator
              if (showOrderButtons && showItemsLayout && !showLangSelector)
                separator(delay: 0.3), // separator
              if (showItemsLayout) ...itemsLayoutSelector(),
              ...widget.additionalIconButtons,
            ],
          );
        },
      ),
    );
  }

  List<Widget> itemsLayoutSelector() {
    return [
      FadeInY(
        beginY: 10.0,
        delay: 0.7,
        child: IconButton(
          onPressed: () => widget.onItemsLayoutSelected(ItemsLayout.list),
          icon: Icon(Icons.list),
          color: widget.itemsLayout == ItemsLayout.list
              ? stateColors.primary
              : stateColors.foreground.withOpacity(0.5),
        ),
      ),
      FadeInY(
        beginY: 10.0,
        delay: 0.8,
        child: IconButton(
          onPressed: () => widget.onItemsLayoutSelected(ItemsLayout.grid),
          icon: Icon(Icons.grid_on),
          color: widget.itemsLayout == ItemsLayout.grid
              ? stateColors.primary
              : stateColors.foreground.withOpacity(0.5),
        ),
      ),
    ];
  }

  Widget langSelector() {
    return FadeInY(
      beginY: 10.0,
      delay: 0.4,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: DropdownButton<String>(
          elevation: 2,
          value: widget.lang,
          isDense: true,
          underline: Container(
            height: 0,
            color: Colors.deepPurpleAccent,
          ),
          icon: Icon(Icons.keyboard_arrow_down),
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

  List<Widget> orderButtons() {
    final descending = widget.descending;

    return [
      FadeInY(
        beginY: 10.0,
        delay: 0.0,
        child: ChoiceChip(
          label: Text(
            'First added',
            style: TextStyle(
              color: !descending ? Colors.white : stateColors.foreground,
            ),
          ),
          tooltip: 'Order by first added',
          selected: !descending,
          selectedColor: stateColors.primary,
          onSelected: (selected) => widget.onDescendingChanged(!descending),
        ),
      ),
      FadeInY(
        beginY: 10.0,
        delay: 0.1,
        child: ChoiceChip(
          label: Text(
            'Last added',
            style: TextStyle(
              color: descending ? Colors.white : stateColors.foreground,
            ),
          ),
          tooltip: 'Order by most recently added',
          selected: descending,
          selectedColor: stateColors.primary,
          onSelected: (selected) => widget.onDescendingChanged(!descending),
        ),
      ),
    ];
  }

  Widget separator({double delay = 0.0}) {
    return FadeInY(
      beginY: 10.0,
      delay: delay,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 20.0,
          right: 20.0,
        ),
        child: Container(
          height: 25,
          width: 2.0,
          color: stateColors.foreground.withOpacity(0.5),
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
