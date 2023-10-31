import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/components/expand_input_chip.dart";
import "package:kwotes/types/author.dart";

class AddAuthorMetadaWrap extends StatelessWidget {
  /// A component showing author's metadata
  /// (e.g. birth date, death date, fictional) in a wrap.
  /// Each data is wrapped in a chip.
  const AddAuthorMetadaWrap({
    super.key,
    required this.author,
    this.randomAuthorInt = 0,
    this.onTapBirthDate,
    this.onTapDeathDate,
    this.onToggleNagativeBirthDate,
    this.onToggleNagativeDeathDate,
    this.onProfilePictureChanged,
    this.onToggleIsFictional,
    this.show = true,
  });

  /// Main page data.
  final Author author;

  /// Show this widget if true.
  final bool show;

  /// Random int for displaying hint texts.
  final int randomAuthorInt;

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

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);

    final String birthText = author.birth.dateEmpty
        ? "quote.add.author.dates.$randomAuthorInt.birth".tr()
        : Jiffy.parseFromDateTime(author.birth.date).yMMMMd;

    final String deathText = author.death.dateEmpty
        ? "quote.add.author.dates.$randomAuthorInt.death".tr()
        : Jiffy.parseFromDateTime(author.death.date).yMMMMd;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        ExpandInputChip(
          tooltip: "quote.add.author.avatar".tr(),
          avatar: CircleAvatar(
            radius: 14.0,
            backgroundImage: const AssetImage("assets/images/autoportrait.png"),
            foregroundImage: author.urls.image.isNotEmpty
                ? NetworkImage(author.urls.image)
                : null,
          ),
          hintText: "quote.add.links.example.web".tr(),
          onTextChanged: onProfilePictureChanged,
        ),
        BetterActionChip(
          onPressed: onTapBirthDate,
          tooltip: "quote.add.author.dates.birth".tr(),
          avatar: Icon(TablerIcons.cake, color: iconColor),
          label: Text(birthText),
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
        if (deathText.isNotEmpty)
          BetterActionChip(
            onPressed: onTapDeathDate,
            tooltip: "quote.add.author.dates.death".tr(),
            avatar: Icon(TablerIcons.skull, color: iconColor),
            label: Text(deathText),
          ),
        if (deathText.isNotEmpty)
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
        BetterActionChip(
          avatar: null,
          tooltip: "quote.add.author"
                  ".fictional.explanation.${author.isFictional}"
              .tr(),
          label: Text(
            "quote.add.author.fictional.${author.isFictional}".tr(),
          ),
          onPressed: onToggleIsFictional,
        ),
      ],
    );
  }
}
