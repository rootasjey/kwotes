import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/reference/reference_metadata_column.dart";
import "package:kwotes/screens/reference/reference_metadata_row.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/reference.dart";

class ReferencePageBody extends StatelessWidget {
  const ReferencePageBody({
    super.key,
    required this.reference,
    this.isDark = false,
    this.isMobileSize = false,
    this.areMetadataOpen = true,
    this.randomColor,
    this.pageState = EnumPageState.idle,
    this.maxHeight = double.infinity,
    this.onDoubleTapName,
    this.onDoubleTapSummary,
    this.onFinishedAnimation,
    this.onTapSeeQuotes,
    this.onTapPoster,
    this.onToggleMetadata,
    this.referenceNameTextStyle = const TextStyle(),
  });

  /// Expand this widget if true.
  final bool areMetadataOpen;

  /// Dark mode.
  final bool isDark;

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Random topic color.
  final Color? randomColor;

  /// Max height.
  final double maxHeight;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback fired when the reference name is double tapped.
  final void Function()? onDoubleTapName;

  /// Callback fired when the reference summary is double tapped.
  final void Function()? onDoubleTapSummary;

  /// Callback fired when reference biography text animation has finished.
  final void Function()? onFinishedAnimation;

  /// Callback fired when the "see related quotes" button is tapped.
  final void Function()? onTapSeeQuotes;

  /// Callback fired when the reference's poster is tapped.
  final void Function(Reference reference)? onTapPoster;

  /// Callback fired to toggle reference metadata widget size.
  final void Function()? onToggleMetadata;

  /// Reference data for this component.
  final Reference reference;

  /// Reference name text style.
  final TextStyle referenceNameTextStyle;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "${"reference.loading".tr()}...",
      );
    }

    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final double leftPadding = isMobileSize ? 24.0 : 48.0;
    const double rightPadding = 24.0;

    return SliverPadding(
      padding: const EdgeInsets.only(
        bottom: 190.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          GestureDetector(
            onDoubleTap: onDoubleTapName,
            onLongPress: () => onTapPoster?.call(reference),
            child: Padding(
              padding: EdgeInsets.only(
                left: leftPadding,
                right: rightPadding,
              ),
              child: Hero(
                tag: reference.name,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    reference.name,
                    softWrap: true,
                    style: referenceNameTextStyle,
                  ),
                ),
              ),
            ),
          ),
          ReferenceMetadaColumn(
            isDark: isDark,
            reference: reference,
            foregroundColor: foregroundColor,
            isOpen: areMetadataOpen,
            onToggleOpen: onToggleMetadata,
            margin: EdgeInsets.only(
              left: leftPadding - 6.0,
              right: rightPadding,
              bottom: 24.0,
            ),
            show: isMobileSize,
          ),
          ReferenceMetadaRow(
            reference: reference,
            opened: areMetadataOpen,
            onTapPoster: onTapPoster,
            onToggleOpen: onToggleMetadata,
            foregroundColor: foregroundColor,
            margin: EdgeInsets.only(
              bottom: 24.0,
              left: leftPadding,
              right: rightPadding,
            ),
            show: !isMobileSize,
          ),
          GestureDetector(
            onDoubleTap: onDoubleTapSummary,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800.0,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: leftPadding,
                  right: rightPadding,
                ),
                child: DefaultTextStyle(
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: isMobileSize ? 16.0 : 28.0,
                      color: foregroundColor.withOpacity(0.6),
                      fontWeight: isMobileSize ? null : FontWeight.w300,
                    ),
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                    onFinished: onFinishedAnimation,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        reference.summary,
                        speed: const Duration(milliseconds: 3),
                        curve: Curves.decelerate,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: leftPadding,
                right: rightPadding,
                top: 32.0,
              ),
              child: TextButton(
                onPressed: onTapSeeQuotes,
                style: TextButton.styleFrom(
                  backgroundColor: randomColor?.withOpacity(0.1),
                  foregroundColor: randomColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "see_related_quotes".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Icon(TablerIcons.arrow_right, size: 16.0),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .slideY(
                begin: 0.8,
                end: 0.0,
                duration: 250.ms,
              )
              .fadeIn(),
        ]),
      ),
    );
  }
}
