import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_action_chip.dart";
import "package:kwotes/components/expand_input_chip.dart";
import "package:kwotes/types/reference.dart";

class AddReferenceMetadataWrap extends StatelessWidget {
  const AddReferenceMetadataWrap({
    super.key,
    required this.show,
    required this.reference,
    this.iconColor,
    this.onPictureUrlChanged,
    this.onToggleNagativeReleaseDate,
    this.onTapReleaseDate,
    this.releaseText = "",
  });

  /// Show this widget if true.
  final bool show;

  /// Icon color.
  final Color? iconColor;

  /// Callback fired when text value for profile picture has changed.
  final void Function(String url)? onPictureUrlChanged;

  /// Callback fired when BCE birth date chip is tapped.
  final void Function()? onToggleNagativeReleaseDate;

  /// Callback fired when birth date chip is tapped.
  final void Function()? onTapReleaseDate;

  /// Reference data.
  final Reference reference;

  /// Release date text.
  final String releaseText;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        ExpandInputChip(
          tooltip: "quote.add.reference.avatar".tr(),
          avatar: CircleAvatar(
            radius: 14.0,
            backgroundImage: const AssetImage("assets/images/autoportrait.png"),
            foregroundImage: reference.urls.image.isNotEmpty
                ? NetworkImage(reference.urls.image)
                : null,
          ),
          hintText: "quote.add.links.example.web".tr(),
          onTextChanged: onPictureUrlChanged,
        ),
        BetterActionChip(
          onPressed: onTapReleaseDate,
          tooltip: "quote.add.reference.dates.release".tr(),
          avatar: Icon(TablerIcons.rocket, color: iconColor),
          label: Text(releaseText),
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
    );
  }
}
