import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/primary_genre_input.dart";
import "package:kwotes/screens/add_quote/secondary_genre_input.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/types/reference.dart";

class AddReferenceMetadaColumn extends StatelessWidget {
  /// A component showing reference's metadata
  /// (e.g. release date) vertically.
  /// Each data is wrapped in a chip.
  const AddReferenceMetadaColumn({
    super.key,
    required this.reference,
    this.isOpen = true,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.randomReferenceInt = 0,
    this.onPrimaryGenreChanged,
    this.onProfilePictureChanged,
    this.onSecondaryGenreChanged,
    this.onToggleOpen,
    this.onToggleNagativeReleaseDate,
    this.onTapReleaseDate,
    this.releaseText = "",
  });

  /// Main page data.
  final Reference reference;

  /// Expand this widget if true.
  final bool isOpen;

  /// Show this widget if true.
  final bool show;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Random int for displaying hint texts.
  final int randomReferenceInt;

  /// Callback fired when BCE birth date chip is tapped.
  final void Function()? onToggleNagativeReleaseDate;

  /// Callback fired when birth date chip is tapped.
  final void Function()? onTapReleaseDate;

  /// Callback fired when text value for profile picture has changed.
  final void Function(String url)? onProfilePictureChanged;

  /// Callback fired when main genre has changed.
  final void Function(String primaryGenre)? onPrimaryGenreChanged;

  /// Callback fired when secondary genre has changed.
  final void Function(String primaryGenre)? onSecondaryGenreChanged;

  /// Callback fired to toggle this widget size.
  final void Function()? onToggleOpen;

  /// Release date text.
  final String releaseText;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    const EdgeInsets itemPadding = EdgeInsets.only(bottom: 6.0);

    final Color? iconColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);

    List<Widget> children = [
      Padding(
        padding: itemPadding,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14.0,
              backgroundImage:
                  const AssetImage("assets/images/reference-picture-0.png"),
              foregroundImage: reference.urls.image.isNotEmpty
                  ? NetworkImage(reference.urls.image)
                  : null,
            ),
            Expanded(
              child: TextFormField(
                initialValue: reference.urls.image,
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
          children: [
            Expanded(
              child: ColoredTextButton(
                icon: Icon(TablerIcons.rocket, color: iconColor),
                margin: const EdgeInsets.only(right: 8.0),
                onPressed: onTapReleaseDate,
                textValue: releaseText,
                tooltip: "quote.add.reference.dates.release".tr(),
              ),
            ),
            BetterActionChip(
              avatar: reference.release.beforeCommonEra
                  ? const Icon(TablerIcons.arrow_back)
                  : const Icon(TablerIcons.arrow_forward),
              tooltip: "quote.add.reference.dates.negative.release"
                      ".explanation.${reference.release.beforeCommonEra}"
                  .tr(),
              label: Text(
                "quote.add.reference.dates.negative.release"
                        ".${reference.release.beforeCommonEra}"
                    .tr(),
              ),
              onPressed: onToggleNagativeReleaseDate,
            ),
          ],
        ),
      ),
      Padding(
        padding: itemPadding,
        child: PrimaryGenreInput(
          selectedPrimaryGenre: reference.type.primary,
          onPrimaryGenreChanged: onPrimaryGenreChanged,
          primaryHintText:
              "quote.add.reference.genres.primary.$randomReferenceInt".tr(),
        ),
      ),
      Padding(
        padding: itemPadding,
        child: SecondaryGenreInput(
          selectedSecondaryGenre: reference.type.secondary,
          onSecondaryGenreChanged: onSecondaryGenreChanged,
          secondaryHintText: reference.type.secondary.isEmpty
              ? "genre.secondary.name".tr()
              : reference.type.secondary,
        ),
      ),
    ];

    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOpen)
            ColoredTextButton(
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
