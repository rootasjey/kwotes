import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    Key? key,
    required this.iconData,
    required this.textSubtitle,
    required this.textTitle,
    this.compact = false,
    this.isWide = false,
    this.noSizeConstraints = false,
    this.backgroundColor,
    this.hoverColor = Colors.pink,
    this.elevation = 0.0,
    this.onTap,
    this.heroKey = "",
  }) : super(key: key);

  /// If true, this card won't have size constrains
  /// (height = 116.0 and width = 200 || 300).
  final bool noSizeConstraints;

  /// This card will have less height but with normal width.
  final bool isWide;

  /// If true, the card's width will be 200.0.
  final bool compact;

  /// Card's background color.
  final Color? backgroundColor;

  /// Icon will be of this color on hover.
  final Color hoverColor;

  /// Card's elevation.
  final double elevation;

  /// Icon's data which will be displayed before text.
  final IconData iconData;

  /// Hero animation key.
  final String heroKey;

  /// Primary card's text.
  final String textTitle;

  /// Secondary card's text.
  final String textSubtitle;

  /// Callback fired when this card is tapped.
  final Function()? onTap;

  @override
  createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  /// Card's current elevation.
  double _elevation = 0.0;

  /// Card's end elevation.
  double _endElevation = 0.0;

  /// Card's start elevation.
  double _startElevation = 0.0;

  /// Card's current icon color.
  Color? _iconColor;

  @override
  void initState() {
    super.initState();
    _startElevation = widget.compact ? 6.0 : widget.elevation;
    _endElevation = _startElevation / 2;
    _elevation = _startElevation;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return compactLayout();
    }

    return largeLayout();
  }

  Widget compactLayout() {
    return Card(
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          color: _iconColor ?? Colors.transparent,
        ),
      ),
      color: widget.backgroundColor,
      surfaceTintColor: widget.hoverColor,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: widget.hoverColor,
        onHover: onHover,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon(),
              texts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget largeLayout() {
    return SizedBox(
      width: 180.0,
      height: 170.0,
      child: Card(
        elevation: _elevation,
        color: widget.backgroundColor,
        surfaceTintColor: widget.hoverColor,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(
            color: _iconColor ?? Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          splashColor: widget.hoverColor,
          onHover: onHover,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          child: Padding(
            padding: widget.compact
                ? const EdgeInsets.all(12.0)
                : const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon(),
                texts(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget icon() {
    return Padding(
      padding: widget.compact
          ? const EdgeInsets.only(right: 12.0)
          : const EdgeInsets.only(
              top: 12.0,
              bottom: 12.0,
            ),
      child: Opacity(
        opacity: 0.6,
        child: Icon(
          widget.iconData,
          color: _iconColor,
        ),
      ),
    );
  }

  Widget texts() {
    return Column(
      crossAxisAlignment:
          widget.compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Hero(
          tag: widget.heroKey,
          child: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.6,
              child: Text(
                widget.textTitle,
                textAlign: TextAlign.center,
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.4,
          child: Text(
            widget.textSubtitle,
            maxLines: widget.isWide ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Utils.calligraphy.body(
              textStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onHover(bool isHover) {
    if (isHover) {
      setState(() {
        _elevation = _endElevation;
        _iconColor = widget.hoverColor;
      });
      return;
    }

    setState(() {
      _elevation = _startElevation;
      _iconColor = null;
    });
  }

  void onTapDown(TapDownDetails details) {
    setState(() {
      _elevation = 0.0;
    });
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _elevation = _startElevation;
    });
  }
}
