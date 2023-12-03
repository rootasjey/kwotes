import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/reference_poster.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

class ReferenceGrid extends StatelessWidget {
  const ReferenceGrid({
    super.key,
    this.isDark = false,
    this.backgroundColor,
    this.foregroundColor,
    this.margin = EdgeInsets.zero,
    this.references = const [],
    this.onTapReference,
    this.onHoverReference,
    this.referenceHoveredId = "",
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// List of references.
  final List<Reference> references;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback fired when reference is hovered.
  final void Function(Reference reference, bool isHover)? onHoverReference;

  /// Reference's id that is currently hovered.
  final String referenceHoveredId;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: margin,
        color: isDark
            ? Color.alphaBlend(Colors.black45, Colors.grey.shade900)
            : backgroundColor?.withOpacity(0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                "reference.names".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: foregroundColor?.withOpacity(0.7),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "reference.latest_added".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: references.map((Reference reference) {
                final bool selected = referenceHoveredId == reference.id;
                final Color accentColor = [
                  Constants.colors.primary,
                  Constants.colors.secondary,
                  Constants.colors.tertiary,
                ].elementAt(reference.id.hashCode.abs() % 3);

                return SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: ReferencePoster(
                    reference: reference,
                    onTap: onTapReference,
                    onHover: onHoverReference,
                    selected: selected,
                    maxLines: 5,
                    accentColor: selected ? accentColor : null,
                    overflow: TextOverflow.ellipsis,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: selected ? accentColor : Colors.transparent,
                        width: 4.0,
                      ),
                    ),
                    titleTextStyle: Utils.calligraphy.body(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
