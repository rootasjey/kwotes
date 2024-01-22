import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/types/enums/enum_search_category.dart";

class ShowMoreButton extends StatelessWidget {
  const ShowMoreButton({
    super.key,
    required this.searchCategory,
    this.show = true,
    this.onPressed,
  });

  /// Show this widget if true.
  final bool show;

  /// What type of category we are searching.
  final EnumSearchCategory searchCategory;

  /// Callback fired when button is tapped.
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final String textValue = searchCategory == EnumSearchCategory.authors
        ? "author.show_more".tr()
        : "reference.show_more".tr();

    final Color accentColor = Constants.colors.getSearchColor(searchCategory);

    return SliverToBoxAdapter(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300.0, minWidth: 0.0),
          child: ColoredTextButton(
            textValue: textValue,
            onPressed: onPressed,
            iconOnRight: true,
            accentColor: accentColor,
            icon: const Icon(TablerIcons.arrow_narrow_down),
            margin: const EdgeInsets.only(left: 12.0),
            style: TextButton.styleFrom(
              backgroundColor: accentColor.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }
}
