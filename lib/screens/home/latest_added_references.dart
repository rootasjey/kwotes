import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

class LatestAddedReferences extends StatelessWidget {
  const LatestAddedReferences({
    super.key,
    required this.references,
    this.hideFirstDivider = false,
    this.isDark = false,
    this.onTapReference,
    this.textColor,
    this.margin = EdgeInsets.zero,
  });

  /// Whether to hide the first divider.
  final bool hideFirstDivider;

  /// Whether to use dark theme.
  final bool isDark;

  /// Foreground text color.
  final Color? textColor;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTapReference;

  /// List of references (main data).
  final List<Reference> references;

  @override
  Widget build(BuildContext context) {
    if (references.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: margin,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 32.0,
                  top: 8.0,
                  bottom: 12.0,
                ),
                child: Text(
                  "reference.latest_added".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: textColor?.withOpacity(0.4),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text.rich(
                  TextSpan(children: [
                    for (Reference reference in references)
                      TextSpan(
                        text: "${reference.name} ".toLowerCase(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => onTapReference?.call(reference),
                        style: TextStyle(
                          color: Constants.colors.getRandomFromPalette(
                            withGoodContrast: !isDark,
                          ),
                        ),
                      ),
                  ]),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: textColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
