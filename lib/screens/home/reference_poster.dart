import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

class ReferencePoster extends StatefulWidget {
  const ReferencePoster({
    super.key,
    required this.reference,
    this.selected = false,
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  /// Selected if true.
  /// Display image in full color. Otherwise it will be grayscale.
  final bool selected;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTap;

  /// Reference to display.
  final Reference reference;

  @override
  State<ReferencePoster> createState() => _ReferencePosterState();
}

class _ReferencePosterState extends State<ReferencePoster> {
  double _titleOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final Reference reference = widget.reference;

    final Object image = reference.urls.image.isNotEmpty
        ? NetworkImage(reference.urls.image)
        : const AssetImage("assets/images/reference-picture-0.png");

    final Ink inkImage = Ink.image(
      image: image as ImageProvider,
      fit: BoxFit.cover,
      colorFilter: widget.selected
          ? null
          : const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
      child: InkWell(
        splashColor: Colors.deepPurple,
        onTap: () => widget.onTap?.call(widget.reference),
        onHover: (value) => setState(() => _titleOpacity = value ? 1.0 : 0.0),
      ),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
      padding: widget.margin,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
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
                    style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 32.0,
                    )),
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
