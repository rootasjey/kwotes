import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/components/reference_poster.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

class ReferenceMetadaRow extends StatelessWidget {
  const ReferenceMetadaRow({
    super.key,
    required this.reference,
    required this.foregroundColor,
    this.opened = true,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.onTapPoster,
    this.onToggleOpen,
  });

  /// Expand this widget if true.
  final bool opened;

  /// Hide this widget if true.
  /// Default to true.
  final bool show;

  /// Text foreground color.
  final Color foregroundColor;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when avatar is tapped.
  final void Function(Reference reference)? onTapPoster;

  /// Callback fired to toggle this widget size.
  final void Function()? onToggleOpen;

  /// Reference data for this component.
  final Reference reference;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final TextStyle chipTextStyle = Utils.calligraphy.body(
      textStyle: TextStyle(
        color: foregroundColor.withOpacity(0.6),
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
    );

    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!opened)
            ColoredTextButton(
              icon: const Icon(TablerIcons.eye, size: 16.0),
              onPressed: onToggleOpen,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              textValue: "see_metadata".tr(),
              textStyle: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          if (opened)
            ColoredTextButton(
              icon: const Icon(TablerIcons.x, size: 16.0),
              onPressed: onToggleOpen,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              textValue: "close".tr(),
              textStyle: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          AnimatedSize(
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              height: opened ? null : 0.0,
              width: opened ? null : 0.0,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (reference.urls.image.isNotEmpty)
                    SizedBox(
                      height: 54.0,
                      width: 54.0,
                      child: ReferencePoster(
                        onTap: onTapPoster,
                        reference: reference,
                        heroTag: "${reference.id}-avatar",
                        selected: true,
                      ),
                    ),
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
                              "genre.primary.${reference.type.primary.toLowerCase()}"
                                  .tr(),
                              style: chipTextStyle,
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
                              reference.type.secondary,
                              style: chipTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!reference.release.isEmpty)
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
                                style: chipTextStyle,
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
            ),
          ),
        ],
      ),
    );
  }
}
