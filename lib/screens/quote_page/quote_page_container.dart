import "dart:ui";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:dismissible_page/dismissible_page.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class QuotePageContainer extends StatelessWidget {
  /// Quote page container (wrapper).
  const QuotePageContainer({
    super.key,
    required this.borderColor,
    required this.child,
    this.isMobileSize = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.heroTag = "",
    this.onTapOutsideChild,
  });

  /// Adapt user interface to small screens.
  final bool isMobileSize;

  /// Border radius for this widget.
  final BorderRadiusGeometry borderRadius;

  /// Border color.
  final Color borderColor;

  /// Callback fired when user taps outside this widget.
  final void Function()? onTapOutsideChild;

  /// Tag for hero animation.
  final String heroTag;

  /// Child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Brightness? brightness = AdaptiveTheme.of(context).brightness;
    final Color backgroundColor =
        brightness == Brightness.light ? Colors.white70 : Colors.black26;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: onTapOutsideChild,
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding:
                isMobileSize ? EdgeInsets.zero : const EdgeInsets.all(42.0),
            child: GestureDetector(
              onTap: () {},
              child: Hero(
                tag: heroTag,
                child: DismissiblePage(
                  onDismissed: () => Utils.passage.deepBack(context),
                  backgroundColor: Colors.transparent,
                  child: Material(
                    elevation: 8.0,
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: borderColor,
                        width: isMobileSize ? 8.0 : 0.5,
                      ),
                      borderRadius: borderRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
