import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    Key? key,
    required this.iconData,
    required this.textSubtitle,
    required this.textTitle,
    this.compact = false,
    this.isDark = false,
    this.isWide = false,
    this.noSizeConstraints = false,
    this.hoverColor = Colors.pink,
    this.elevation = 0.0,
    this.onTap,
    this.heroKey = "",
  }) : super(key: key);

  /// If true, this card won't have size constrains
  /// (height = 116.0 and width = 200 || 300).
  final bool noSizeConstraints;

  /// If true, this card will be dark.
  final bool isDark;

  /// This card will have less height but with normal width.
  final bool isWide;

  /// If true, the card's width will be 200.0.
  final bool compact;

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

  /// Shake animation value target (to animate on hover).
  double _shakeAnimationTarget = 0.0;

  /// Card's start elevation.
  double _startElevation = 0.0;

  /// Card's background color.
  Color? _backgroundColor;

  /// Card's border color.
  Color? _borderColor;

  /// Card's current icon color.
  Color? _iconColor;

  @override
  void initState() {
    super.initState();
    _startElevation = widget.compact ? 6.0 : widget.elevation;
    _endElevation = _startElevation / 2;
    _elevation = _startElevation;

    widget.isDark ? applyDarkTheme() : applyLightTheme();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return compactLayout();
    }

    return largeLayout();
  }

  /// Apply dark theme.
  void applyDarkTheme() {
    _elevation = _endElevation;
    _iconColor = widget.hoverColor;
    _borderColor = widget.hoverColor.withOpacity(0.2);
    _backgroundColor = null;
  }

  /// Apply light theme.
  void applyLightTheme() {
    _elevation = _startElevation;
    _iconColor = widget.hoverColor;
    _borderColor = widget.hoverColor.withOpacity(0.2);
  }

  Widget compactLayout() {
    return Card(
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          color: _borderColor ?? Colors.transparent,
        ),
      ),
      color: _backgroundColor,
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
        color: _backgroundColor,
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
      child: Icon(
        widget.iconData,
        color: _iconColor,
      ).animate(target: _shakeAnimationTarget).shake(),
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
            child: Text(
              widget.textTitle,
              textAlign: TextAlign.center,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: _iconColor,
                ),
              ),
            ),
          ),
        ),
        // Opacity for dark/ligth theme auto switch.
        Opacity(
          opacity: 0.6,
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

  /// Callback fired when this card is hovered.
  void onHover(bool isHover) {
    widget.isDark ? onDarkHover(isHover) : onLightHover(isHover);
  }

  /// On hover ind dark theme.
  void onDarkHover(bool isHover) {
    if (isHover) {
      setState(() {
        _elevation = _startElevation;
        _borderColor = widget.hoverColor;
        _shakeAnimationTarget = 1.0;
      });
      return;
    }

    setState(() {
      applyDarkTheme();
      _shakeAnimationTarget = 0.0;
    });
  }

  /// On hover in light theme.
  void onLightHover(bool isHover) {
    if (isHover) {
      setState(() {
        _elevation = _endElevation;
        _iconColor = widget.hoverColor;
        _borderColor = widget.hoverColor;
        _shakeAnimationTarget = 1.0;
      });
      return;
    }

    setState(() {
      applyLightTheme();
      _shakeAnimationTarget = 0.0;
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
