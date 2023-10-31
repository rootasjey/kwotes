import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/types/reference.dart";

class ReferenceMetadaRow extends StatelessWidget {
  const ReferenceMetadaRow({
    super.key,
    required this.reference,
    required this.foregroundColor,
    this.show = true,
    this.margin = EdgeInsets.zero,
  });

  /// Reference data for this component.
  final Reference reference;

  /// Hide this widget if true.
  /// Default to true.
  final bool show;

  /// Text foreground color.
  final Color foregroundColor;

  /// Space around this widget.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: margin,
      child: Wrap(
        children: [
          if (reference.type.primary.isNotEmpty)
            Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        TablerIcons.triangle,
                        color: foregroundColor.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      "genre.primary.${reference.type.primary}".tr(),
                    ),
                  ],
                ),
              ),
            ),
          if (reference.type.secondary.isNotEmpty)
            Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        TablerIcons.hexagon,
                        color: foregroundColor.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      "genre.secondary.${reference.type.secondary.toLowerCase()}"
                          .tr(),
                    ),
                  ],
                ),
              ),
            ),
          if (!reference.release.dateEmpty)
            JustTheTooltip(
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("release_date".tr()),
              ),
              child: Card(
                elevation: 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          TablerIcons.jetpack,
                          color: foregroundColor.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        Jiffy.parseFromDateTime(
                          reference.release.original,
                        ).yMMMMd,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ]
            .animate(interval: 100.ms)
            .fadeIn(duration: 300.ms, curve: Curves.decelerate)
            .slideX(begin: 0.2, end: 0.0),
      ),
    );
  }
}
