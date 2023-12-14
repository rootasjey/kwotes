import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorMetadataRow extends StatelessWidget {
  const AuthorMetadataRow({
    super.key,
    required this.author,
    required this.foregroundColor,
    this.opened = true,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.onTapAvatar,
    this.onToggleOpen,
  });

  /// Author data for this component.
  final Author author;

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
  final void Function()? onTapAvatar;

  /// Callback fired to toggle this widget size.
  final void Function()? onToggleOpen;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
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
                  if (author.urls.image.isNotEmpty)
                    BetterAvatar(
                      imageProvider: NetworkImage(author.urls.image),
                      radius: 24.0,
                      onTap: onTapAvatar,
                    ),
                  if (author.job.isNotEmpty)
                    Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                TablerIcons.briefcase,
                                color: foregroundColor.withOpacity(0.6),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Text(
                                author.job,
                                style: chipTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!author.birth.isDateEmpty)
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
                                TablerIcons.baby_bottle,
                                color: foregroundColor.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              Jiffy.parseFromDateTime(author.birth.date).yMMMMd,
                              style: chipTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!author.death.isDateEmpty)
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
                                TablerIcons.skull,
                                color: foregroundColor.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              Jiffy.parseFromDateTime(author.death.date).yMMMMd,
                              style: chipTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (author.isFictional)
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
                                TablerIcons.wand,
                                color: foregroundColor.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              "fictional".tr(),
                              style: chipTextStyle,
                            ),
                          ],
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
