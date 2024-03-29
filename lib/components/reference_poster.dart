import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

class ReferencePoster extends StatefulWidget {
  const ReferencePoster({
    super.key,
    required this.reference,
    this.selected = false,
    this.margin = EdgeInsets.zero,
    this.accentColor = Colors.transparent,
    this.onTap,
    this.onHover,
    this.maxLines,
    this.heroTag,
    this.shape,
    this.overflow,
    this.titleTextStyle,
  });

  /// Selected if true.
  /// Display image in full color. Otherwise it will be grayscale.
  final bool selected;

  /// Accent color.
  final Color? accentColor;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTap;

  /// Callback fired when reference is hovered.
  final void Function(Reference reference, bool isHover)? onHover;

  /// Title text max lines.
  final int? maxLines;

  /// Hero tag.
  final Object? heroTag;

  /// Reference to display.
  final Reference reference;

  /// Shape of the poster.
  final ShapeBorder? shape;

  /// Title text overflow.
  final TextOverflow? overflow;

  /// Title text style.
  final TextStyle? titleTextStyle;

  @override
  State<ReferencePoster> createState() => _ReferencePosterState();
}

class _ReferencePosterState extends State<ReferencePoster> {
  double _titleOpacity = 0.0;

  final TextStyle _defaultTextStyle = Utils.calligraphy.body(
    textStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 32.0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Reference reference = widget.reference;

    final Object image = reference.urls.image.isNotEmpty
        ? NetworkImage(reference.urls.image)
        : const AssetImage("assets/images/reference-picture-0.png");

    Widget inkImage = Ink.image(
      image: image as ImageProvider,
      fit: BoxFit.cover,
      colorFilter: widget.selected
          ? null
          : const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
      child: InkWell(
        splashColor: widget.accentColor?.withOpacity(0.6),
        onTap: () => widget.onTap?.call(widget.reference),
        onHover: (bool isHover) {
          widget.onHover?.call(widget.reference, isHover);
          setState(() => _titleOpacity = isHover ? 1.0 : 0.0);
        },
      ),
    );

    if (widget.heroTag != null) {
      inkImage = Hero(
        tag: widget.heroTag as Object,
        child: inkImage,
      );
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
      padding: widget.margin,
      child: Card(
        shape: widget.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
              side: BorderSide(
                color: widget.accentColor ?? Colors.transparent,
                width: 2.0,
              ),
            ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _titleOpacity,
                duration: const Duration(milliseconds: 150),
                curve: Curves.decelerate,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    reference.name,
                    overflow: widget.overflow,
                    maxLines: widget.maxLines,
                    style: widget.titleTextStyle ?? _defaultTextStyle,
                  ),
                ),
              ),
            ),
            inkImage,
          ],
        ),
      ),
    );
  }
}
