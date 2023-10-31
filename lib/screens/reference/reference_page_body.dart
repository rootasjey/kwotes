import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/reference/reference_metadata_column.dart";
import "package:kwotes/screens/reference/reference_metadata_row.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/reference.dart";

class ReferencePageBody extends StatelessWidget {
  const ReferencePageBody({
    super.key,
    required this.reference,
    this.isMobileSize = false,
    this.areMetadataOpen = true,
    this.randomColor,
    this.pageState = EnumPageState.idle,
    this.maxHeight = double.infinity,
    this.onTapSeeQuotes,
    this.onTapReferenceName,
    this.onToggleMetadata,
    this.referenceNameTextStyle = const TextStyle(),
  });

  /// Expand this widget if true.
  final bool areMetadataOpen;

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Random topic color.
  final Color? randomColor;

  /// Max height.
  final double maxHeight;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback fired when the "see related quotes" button is tapped.
  final void Function()? onTapSeeQuotes;

  /// Callback fired when the reference name is tapped.
  final void Function()? onTapReferenceName;

  /// Callback fired to toggle reference metadata widget size.
  final void Function()? onToggleMetadata;

  /// Reference data for this component.
  final Reference reference;

  /// Reference name text style.
  final TextStyle referenceNameTextStyle;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "${"reference.loading".tr()}...",
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 24.0 : 48.0,
        right: 24.0,
        bottom: 190.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          GestureDetector(
            onTap: onTapReferenceName,
            child: Padding(
              padding: isMobileSize
                  ? const EdgeInsets.only(bottom: 24.0)
                  : EdgeInsets.zero,
              child: Hero(
                tag: reference.id,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    reference.name,
                    style: Utils.calligraphy.title(
                      textStyle: referenceNameTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ReferenceMetadaColumn(
            reference: reference,
            foregroundColor: foregroundColor,
            isOpen: areMetadataOpen,
            onToggleOpen: onToggleMetadata,
            margin: const EdgeInsets.only(bottom: 24.0),
            show: isMobileSize,
          ),
          AnimatedTextKit(
            isRepeatingAnimation: false,
            displayFullTextOnTap: true,
            animatedTexts: [
              TypewriterAnimatedText(
                reference.summary,
                speed: const Duration(milliseconds: 10),
                curve: Curves.decelerate,
                textStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 16.0 : 24.0,
                    color: foregroundColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          ReferenceMetadaRow(
            reference: reference,
            foregroundColor: foregroundColor,
            margin: const EdgeInsets.only(top: 24.0),
            show: !isMobileSize,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: TextButton(
                onPressed: onTapSeeQuotes,
                style: TextButton.styleFrom(
                  foregroundColor: Constants.colors.getRandomFromPalette(
                    withGoodContrast: true,
                  ),
                ),
                child: Text(
                  "see_related_quotes".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: isMobileSize ? 16.0 : 24.0,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().slideY(begin: 0.8, end: 0.0, duration: 250.ms).fadeIn(),
        ]),
      ),
    );
  }
}
