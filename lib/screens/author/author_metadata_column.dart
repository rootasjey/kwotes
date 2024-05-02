import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/types/author.dart";
import "package:wave_divider/wave_divider.dart";

class AuthorMetadataColumn extends StatelessWidget {
  const AuthorMetadataColumn({
    super.key,
    required this.author,
    required this.foregroundColor,
    this.isDark = false,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.onToggleOpen,
    this.isOpen = true,
  });

  /// Author data for this component.
  final Author author;

  /// Dark mode.
  final bool isDark;

  /// Expand this widget if true.
  final bool isOpen;

  /// Hide this widget if true.
  /// Default to true.
  final bool show;

  /// Text foreground color.
  final Color foregroundColor;

  /// Callback fired to toggle this widget size.
  final void Function()? onToggleOpen;

  /// Space around this widget.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = [];

    final Color iconColor = foregroundColor.withOpacity(0.6);
    const double iconSize = 24.0;
    const EdgeInsets iconPadding = EdgeInsets.only(right: 8.0);

    final TextStyle textStyle = Utils.calligraphy.body(
      textStyle: TextStyle(
        color: iconColor,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        height: 1.6,
      ),
    );

    if (author.job.isNotEmpty) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: iconPadding,
              child: Icon(
                TablerIcons.briefcase,
                color: iconColor,
                size: iconSize,
              ),
            ),
            Expanded(
              child: Text(
                author.job,
                style: textStyle,
              ),
            ),
          ],
        ),
      );
    }

    if (!author.birth.isDateEmpty) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: iconPadding,
              child: Icon(
                TablerIcons.baby_bottle,
                color: iconColor,
                size: iconSize,
              ),
            ),
            Text(
              Jiffy.parseFromDateTime(author.birth.date).yMMMMd,
              style: textStyle,
            ),
          ],
        ),
      );
    }

    if (!author.death.isDateEmpty) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: iconPadding,
              child: Icon(
                TablerIcons.skull,
                color: iconColor,
                size: iconSize,
              ),
            ),
            Text(
              Jiffy.parseFromDateTime(author.death.date).yMMMMd,
              style: textStyle,
            ),
          ],
        ),
      );
    }

    if (author.isFictional) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: iconPadding,
              child: Icon(
                TablerIcons.wand,
                color: iconColor,
                size: iconSize,
              ),
            ),
            Text(
              "fictional".tr(),
              style: textStyle,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOpen)
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
          if (isOpen)
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
              height: isOpen ? null : 0.0,
              child: Card(
                elevation: 8.0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                surfaceTintColor: Colors.grey.shade50,
                color: isDark ? Colors.black : Colors.grey.shade100,
                child: InkWell(
                  onTap: onToggleOpen,
                  borderRadius: BorderRadius.circular(4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: children[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return WaveDivider(
                          color: foregroundColor.withOpacity(0.2),
                        );
                      },
                      itemCount: children.length,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
