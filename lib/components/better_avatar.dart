import "package:flutter/material.dart";

class BetterAvatar extends StatefulWidget {
  const BetterAvatar({
    Key? key,
    required this.imageProvider,
    this.heroTag,
    this.selected = false,
    this.elevation = 4.0,
    this.borderColor = Colors.transparent,
    this.onTap,
    this.colorFilter,
    this.margin = EdgeInsets.zero,
    this.radius = 36.0,
    this.avatarMargin = const EdgeInsets.all(4.0),
    this.onHover,
  }) : super(key: key);

  /// True if the avatar is selected.
  final bool selected;

  /// Avatar's border color when selected.
  final Color borderColor;

  /// Color filter applied to the image.
  /// Not used if onTap is null.
  final ColorFilter? colorFilter;

  /// Avatar's radius.
  final double radius;

  /// Avatar's initial elevation.
  final double elevation;

  /// Space around the avatar.
  final EdgeInsets margin;

  /// Space between the avatar and its border if selected.
  final EdgeInsets avatarMargin;

  /// Callback fired when avatar is hovered.
  final void Function(bool isHovered)? onHover;

  /// Callback fired when avatar is tapped.
  final void Function()? onTap;

  /// Image provider (e.g. network, asset, ...).
  final ImageProvider<Object> imageProvider;

  /// Hero avatar tag.
  final Object? heroTag;

  @override
  State<StatefulWidget> createState() => _BetterAvatarState();
}

class _BetterAvatarState extends State<BetterAvatar>
    with TickerProviderStateMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleAnimationController;

  late double _elevation;

  // Object _heroTag = "image_hero";

  @override
  void initState() {
    super.initState();
    // _heroTag = widget.heroTag ?? DateTime.now();

    _scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    setState(() => _elevation = widget.elevation);
  }

  @override
  dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CircleAvatar avatar = CircleAvatar(
      radius: widget.radius,
      child: ClipOval(
        child: Material(
          elevation: _elevation,
          child: Ink.image(
            image: widget.imageProvider,
            colorFilter: widget.colorFilter,
            fit: BoxFit.cover,
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (final TapDownDetails details) {
                setState(() => _elevation = widget.elevation);
              },
              onHover: (final bool isHover) {
                widget.onHover?.call(isHover);
                if (isHover) {
                  _elevation = (widget.elevation + 1.0) * 2;
                  _scaleAnimationController.forward();
                  setState(() {});
                  return;
                }

                _elevation = widget.elevation;
                _scaleAnimationController.reverse();
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );

    final Widget avatarContainer = widget.heroTag == null
        ? avatar
        : Hero(
            tag: widget.heroTag as Object,
            child: avatar,
          );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: widget.margin,
        child: Container(
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2.0,
              color: widget.selected ? widget.borderColor : Colors.transparent,
            ),
          ),
          child: Padding(
            padding: widget.avatarMargin,
            child: avatarContainer,
          ),
        ),
      ),
    );
  }
}
