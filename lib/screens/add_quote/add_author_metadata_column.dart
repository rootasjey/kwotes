import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/types/author.dart";
import "package:wave_divider/wave_divider.dart";

class AddAuthorMetadaColumn extends StatelessWidget {
  /// A component showing author's metadata
  /// (e.g. birth date, death date, fictional) vertically.
  /// Each data is wrapped in a chip.
  const AddAuthorMetadaColumn({
    super.key,
    required this.author,
    this.isOpen = true,
    this.show = true,
    this.borderSide = BorderSide.none,
    this.margin = EdgeInsets.zero,
    this.onTapBirthDate,
    this.onTapDeathDate,
    this.onToggleNagativeBirthDate,
    this.onToggleNagativeDeathDate,
    this.onProfilePictureChanged,
    this.onToggleIsFictional,
    this.onToggleOpen,
  });

  /// Main page data.
  final Author author;

  /// Expand this widget if true.
  final bool isOpen;

  /// Show this widget if true.
  final bool show;

  /// Card border side.
  final BorderSide borderSide;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired when birth date chip is tapped.
  final void Function()? onTapBirthDate;

  /// Callback fired when death date chip is tapped.
  final void Function()? onTapDeathDate;

  /// Callback fired when BCE birth date chip is tapped.
  final void Function()? onToggleNagativeBirthDate;

  /// Callback fired when BCE death date chip is tapped.
  final void Function()? onToggleNagativeDeathDate;

  /// Callback fired when text value for profile picture has changed.
  final void Function(String url)? onProfilePictureChanged;

  /// Callback fired when fictional value has changed.
  final void Function()? onToggleIsFictional;

  /// Callback fired to toggle this widget size.
  final void Function()? onToggleOpen;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    const EdgeInsets iconPadding = EdgeInsets.only(right: 14.0);
    const EdgeInsets itemPadding = EdgeInsets.only(bottom: 6.0);
    const double iconSize = 18.0;
    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    final String birthText = author.birth.isDateEmpty
        ? "quote.add.author.dates.choose".tr()
        : Jiffy.parseFromDateTime(author.birth.date).yMMMMd;

    final String deathText = author.death.isDateEmpty
        ? "quote.add.author.dates.choose".tr()
        : Jiffy.parseFromDateTime(author.death.date).yMMMMd;

    final ButtonStyle buttonStyle = TextButton.styleFrom(
      foregroundColor: iconColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
    final TextStyle buttonTextStyle = Utils.calligraphy.body(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
      ),
    );

    List<Widget> children = [
      Padding(
        padding: itemPadding,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2.0, right: 4.0),
              child: CircleAvatar(
                radius: 14.0,
                foregroundColor: iconColor,
                backgroundColor: Colors.transparent,
                foregroundImage: author.urls.image.isNotEmpty
                    ? NetworkImage(author.urls.image)
                    : null,
                child: const Icon(TablerIcons.user_circle, size: iconSize),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: author.urls.image,
                textInputAction: TextInputAction.next,
                onChanged: onProfilePictureChanged,
                style: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(
                    left: 6.0,
                  ),
                  hintText: "quote.add.links.example.web".tr(),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: itemPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ColoredTextButton(
                iconPadding: iconPadding,
                icon: Icon(TablerIcons.cake, color: iconColor, size: iconSize),
                margin: const EdgeInsets.only(right: 8.0),
                onPressed: onTapBirthDate,
                textValue: birthText,
                tooltip: "quote.add.author.dates.birth".tr(),
                textStyle: buttonTextStyle,
                style: buttonStyle,
              ),
            ),
            BetterActionChip(
              avatar: author.birth.beforeCommonEra
                  ? const Icon(TablerIcons.arrow_back)
                  : const Icon(TablerIcons.arrow_forward),
              tooltip: "quote.add.author.dates.negative.birth"
                      ".explanation.${author.birth.beforeCommonEra}"
                  .tr(),
              label: Text(
                "quote.add.author.dates.negative"
                        ".birth.${author.birth.beforeCommonEra}"
                    .tr(),
              ),
              onPressed: onToggleNagativeBirthDate,
            ),
          ],
        ),
      ),
      Padding(
        padding: itemPadding,
        child: Row(
          children: [
            Expanded(
              child: ColoredTextButton(
                iconPadding: iconPadding,
                icon: Icon(TablerIcons.skull, color: iconColor, size: iconSize),
                margin: const EdgeInsets.only(right: 8.0),
                onPressed: onTapDeathDate,
                textValue: deathText,
                tooltip: "quote.add.author.dates.death".tr(),
                textStyle: buttonTextStyle,
                style: buttonStyle,
              ),
            ),
            BetterActionChip(
              avatar: author.death.beforeCommonEra
                  ? const Icon(TablerIcons.arrow_back)
                  : const Icon(TablerIcons.arrow_forward),
              tooltip: "quote.add.author.dates.negative"
                      ".death.explanation.${author.death.beforeCommonEra}"
                  .tr(),
              label: Text(
                "quote.add.author.dates.negative"
                        ".death.${author.death.beforeCommonEra}"
                    .tr(),
              ),
              onPressed: onToggleNagativeDeathDate,
            ),
          ],
        ),
      ),
      ColoredTextButton(
        iconPadding: iconPadding,
        onPressed: onToggleIsFictional,
        tooltip: "quote.add.author"
                ".fictional.explanation.${author.isFictional}"
            .tr(),
        textValue: "quote.add.author.fictional.${author.isFictional}".tr(),
        icon: Icon(TablerIcons.wand, color: iconColor, size: iconSize),
        textStyle: buttonTextStyle,
        style: buttonStyle,
      ),
    ];

    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOpen)
            ColoredTextButton(
              backgroundColor:
                  Theme.of(context).buttonTheme.colorScheme?.onPrimary,
              icon: const Icon(TablerIcons.eye, size: 16.0),
              onPressed: onToggleOpen,
              textValue: "see_metadata".tr(),
              textStyle: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          if (isOpen)
            ColoredTextButton(
              backgroundColor:
                  Theme.of(context).buttonTheme.colorScheme?.onPrimary,
              icon: const Icon(TablerIcons.x, size: 16.0),
              onPressed: onToggleOpen,
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
            child: Container(
              height: isOpen ? null : 0.0,
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                elevation: 8.0,
                margin: EdgeInsets.zero,
                surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: borderSide,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return children[index];
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return WaveDivider(
                        color: Theme.of(context).dividerColor,
                      );
                    },
                    itemCount: children.length,
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
