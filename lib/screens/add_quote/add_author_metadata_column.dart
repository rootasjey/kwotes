import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/types/author.dart";

class AddAuthorMetadaColumn extends StatelessWidget {
  /// A component showing author's metadata
  /// (e.g. birth date, death date, fictional) vertically.
  /// Each data is wrapped in a chip.
  const AddAuthorMetadaColumn({
    super.key,
    required this.author,
    this.isOpen = true,
    this.show = true,
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

    const EdgeInsets itemPadding = EdgeInsets.only(bottom: 6.0);

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);

    final String birthText = author.birth.isDateEmpty
        ? "quote.add.author.dates.choose".tr()
        : Jiffy.parseFromDateTime(author.birth.date).yMMMMd;

    final String deathText = author.death.isDateEmpty
        ? "quote.add.author.dates.choose".tr()
        : Jiffy.parseFromDateTime(author.death.date).yMMMMd;

    List<Widget> children = [
      Padding(
        padding: itemPadding,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14.0,
              backgroundImage:
                  const AssetImage("assets/images/profile-picture-avocado.png"),
              foregroundImage: author.urls.image.isNotEmpty
                  ? NetworkImage(author.urls.image)
                  : null,
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
                    top: 0.0,
                    right: 0.0,
                    bottom: 0.0,
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
                icon: Icon(TablerIcons.cake, color: iconColor),
                margin: const EdgeInsets.only(right: 8.0),
                onPressed: onTapBirthDate,
                textValue: birthText,
                tooltip: "quote.add.author.dates.birth".tr(),
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
                icon: Icon(TablerIcons.skull, color: iconColor),
                margin: const EdgeInsets.only(right: 8.0),
                onPressed: onTapDeathDate,
                textValue: deathText,
                tooltip: "quote.add.author.dates.death".tr(),
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
        onPressed: onToggleIsFictional,
        tooltip: "quote.add.author"
                ".fictional.explanation.${author.isFictional}"
            .tr(),
        textValue: "quote.add.author.fictional.${author.isFictional}".tr(),
        icon: Icon(TablerIcons.wand, color: iconColor),
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
            child: SizedBox(
              height: isOpen ? null : 0.0,
              child: Card(
                elevation: 8.0,
                margin: EdgeInsets.zero,
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(
                    color: Constants.colors.getRandomFromPalette(),
                  ),
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
                      return const Divider();
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
