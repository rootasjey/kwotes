import "package:flutter/material.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/components/reference_poster.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/reference.dart";

class ReferenceQuotesPageHeader extends StatelessWidget {
  const ReferenceQuotesPageHeader({
    super.key,
    this.isMobileSize = false,
    required this.reference,
    this.onTapName,
    this.onTapPoster,
  });

  /// Whether the screen is narrow.
  final bool isMobileSize;

  /// Reference data for this component.
  final Reference reference;

  /// Callback fired when avatar is tapped.
  final void Function(Reference reference)? onTapPoster;

  /// Callback fired when name is tapped.
  final void Function()? onTapName;

  @override
  Widget build(BuildContext context) {
    return PageAppBar(
      axis: Axis.horizontal,
      toolbarHeight: 120.0,
      children: [
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: ReferencePoster(
            reference: reference,
            accentColor: Constants.colors.getRandomPastel(),
            onTap: onTapPoster,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTapName,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                reference.name,
                style: Utils.calligraphy.title(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 32.0 : 42.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}