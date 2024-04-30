import "package:flutter/material.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class ShowcaseText extends StatefulWidget {
  const ShowcaseText({
    super.key,
    required this.textValue,
    this.isDark = false,
    this.isMobileSize = false,
    this.useSquareAvatar = false,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(2.0),
    this.onTap,
    this.docId = "",
    this.index = 0,
    this.initialForegroundColor,
    this.imageProvider,
    this.subtitleValue = "",
    this.titleHeroTag,
  });

  /// Whether to adapt UI to dark theme.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Use square avatar if true.
  final bool useSquareAvatar;

  /// Initial foreground color.
  final Color? initialForegroundColor;

  /// Index.
  final int index;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Padding around the text.
  final EdgeInsets padding;

  // Callback fired when text is tapped.
  final void Function()? onTap;

  /// Image provider for avatar if any.
  final ImageProvider? imageProvider;

  /// Document ID for hero animation transition.
  final String docId;

  /// Title text.
  final String textValue;

  /// Subtitle text.
  final String subtitleValue;

  /// Title hero tag.
  final Object? titleHeroTag;

  @override
  State<ShowcaseText> createState() => _ShowcaseTextState();
}

class _ShowcaseTextState extends State<ShowcaseText> {
  bool _colorFilterActive = true;

  /// Color on hover.
  Color? _accentColor;

  /// Current text foreground color.
  Color? _foregroundColor = Colors.black;

  /// Initial text foreground color.
  Color? _initialForegroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  /// Initializes properties.
  void initProps() {
    _accentColor = Constants.colors.getRandomFromPalette(
      onlyDarkerColors: !widget.isDark,
    );

    setState(() {
      _initialForegroundColor = widget.initialForegroundColor;
      _foregroundColor = _initialForegroundColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialForegroundColor != widget.initialForegroundColor) {
      _initialForegroundColor = widget.initialForegroundColor;
      initProps();
    }

    final ImageProvider? imageProvider = widget.imageProvider;
    Widget avatar = const SizedBox.shrink();

    if (imageProvider != null && !widget.useSquareAvatar) {
      avatar = BetterAvatar(
        imageProvider: imageProvider,
        radius: 16.0,
        onTap: widget.onTap,
        heroTag: widget.docId,
        colorFilter: _colorFilterActive
            ? const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              )
            : null,
        margin: const EdgeInsets.only(right: 12.0),
      );
    } else if (imageProvider != null && widget.useSquareAvatar) {
      avatar = Hero(
        tag: widget.docId,
        child: Card(
          margin: const EdgeInsets.only(right: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image(
              image: imageProvider,
              fit: BoxFit.cover,
              color: _colorFilterActive ? Colors.grey : null,
              colorBlendMode: BlendMode.saturation,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: widget.margin,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onTapUp: onTapUp,
        splashColor: _foregroundColor?.withOpacity(0.4),
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
        onHover: (bool isHover) {
          setState(() {
            _colorFilterActive = false;
            _foregroundColor = isHover ? _accentColor : _initialForegroundColor;
          });
        },
        child: Padding(
          padding: widget.padding,
          child: Row(
            children: [
              if (imageProvider != null) avatar,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: widget.titleHeroTag ?? ValueKey(widget.index),
                      child: Text(
                        widget.textValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: _foregroundColor,
                          ),
                        ),
                      ),
                    ),
                    if (widget.subtitleValue.isNotEmpty)
                      Text(
                        widget.subtitleValue,
                        style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: _foregroundColor?.withOpacity(0.3),
                        )),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapDown(TapDownDetails details) {
    setState(() {
      _colorFilterActive = false;
    });
  }

  void onTapCancel() {
    setState(() {
      _colorFilterActive = true;
    });
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _colorFilterActive = true;
    });
  }
}
