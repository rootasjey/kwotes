import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/home/home_text_button.dart";
import "package:kwotes/types/reference.dart";

class LatestAddedReferences extends StatelessWidget {
  const LatestAddedReferences({
    super.key,
    required this.references,
    this.hideFirstDivider = false,
    this.onTapReference,
    this.textColor,
  });

  final bool hideFirstDivider;

  /// Foreground text color.
  final Color? textColor;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTapReference;

  /// List of references (main data).
  final List<Reference> references;

  @override
  Widget build(BuildContext context) {
    if (references.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          left: 54.0,
          right: 54.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideFirstDivider) const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
              child: Text(
                "reference.latest_added".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: textColor?.withOpacity(0.4),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            ...references.map((Reference reference) {
              return HomeTextButton(
                textValue: reference.name,
                margin: const EdgeInsets.only(bottom: 8.0),
                onPressed: () => onTapReference?.call(reference),
                textStyle: Utils.calligraphy.body(
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              );
            }),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
