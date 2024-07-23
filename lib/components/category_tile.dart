import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/category.dart";

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.category,
    this.isDark = false,
    this.showName = true,
    this.startElevation = 0.0,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 24.0,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.size = const Size(100.0, 100.0),
    this.shape,
    this.heroTag,
    this.onHover,
    this.trailing,
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Show topic name below icon if true.
  /// Default: true.
  final bool showName;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color.
  final Color? foregroundColor;

  /// Icon's size.
  final double iconSize;

  /// Start elevation value.
  final double startElevation;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Hero tag.
  final Object? heroTag;

  /// Card shape.
  final ShapeBorder? shape;

  /// Card size.
  final Size size;

  /// Category color.
  final Category category;

  /// Callback fired when a category is tapped.
  final void Function(Category category)? onTap;

  /// Callback fired when a category is hovered.
  final void Function(Category category, bool isHover)? onHover;

  /// Trailing widget.
  final Widget? trailing;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  /// Icon color.
  Color? _iconColor = Colors.black;

  /// Icon color on hover.
  Color? _iconHoverColor = Colors.black;

  /// Card's elevation on start.
  double _cardElevation = 0.0;

  /// Card's elevation on hover.
  final double _endElevation = 0.0;

  /// Shake animation value target (to animate on hover).
  double _shakeAnimationTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _iconColor = widget.foregroundColor?.withOpacity(0.6);
    _iconHoverColor = widget.category.color;
    _cardElevation = widget.startElevation;
  }

  @override
  Widget build(BuildContext context) {
    final Category category = widget.category;
    final Widget? trailing = widget.trailing;

    return Card(
      margin: widget.margin,
      elevation: _cardElevation,
      color: widget.backgroundColor,
      shadowColor: _iconHoverColor?.withOpacity(0.2),
      surfaceTintColor: _iconHoverColor,
      shape: widget.shape,
      child: InkWell(
        customBorder: widget.shape,
        borderRadius: BorderRadius.circular(12.0),
        splashColor: _iconHoverColor?.withOpacity(0.6),
        onTap: widget.onTap != null ? () => widget.onTap?.call(category) : null,
        onHover: (bool isHover) {
          widget.onHover?.call(category, isHover);

          if (isHover) {
            setState(() {
              _cardElevation = widget.startElevation / 2.0;
              _iconColor = _iconHoverColor;
              _shakeAnimationTarget = 1.0;
            });

            return;
          }

          setState(() {
            _cardElevation = widget.startElevation;
            _shakeAnimationTarget = 0.0;
            _iconColor = _iconHoverColor?.withOpacity(0.6);
          });
        },
        onTapDown: (details) {
          setState(() => _cardElevation = _endElevation);
        },
        onTapUp: (details) {
          setState(() => _cardElevation = widget.startElevation);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Utils.graphic.getIconDataFromCategory(category.name),
                color: widget.isDark ? _iconColor : null,
                size: widget.iconSize,
              ).animate(target: _shakeAnimationTarget).shake(),
              if (widget.showName)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Hero(
                      tag: widget.heroTag ?? category.name,
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 12.0,
                            color: widget.isDark
                                ? category.color
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: widget.isDark
                                    ? Colors.black
                                    : category.color.withOpacity(0.8),
                                offset: widget.isDark
                                    ? const Offset(1, 1)
                                    : const Offset(2, 2),
                                blurRadius: widget.isDark ? 1.0 : 4.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}
