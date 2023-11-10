import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/author/author_metadata_column.dart";
import "package:kwotes/screens/author/author_metadata_row.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";

class AuthorPageBody extends StatelessWidget {
  const AuthorPageBody({
    super.key,
    required this.author,
    this.areMetadataOpen = true,
    this.isDark = false,
    this.isMobileSize = false,
    this.randomColor,
    this.maxHeight = double.infinity,
    this.pageState = EnumPageState.idle,
    this.onTapSeeQuotes,
    this.onTapAuthorName,
    this.onToggleMetadata,
    this.authorNameTextStyle = const TextStyle(),
  });

  /// Author data for this component.
  final Author author;

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

  /// Callback fired when the author name is tapped.
  final void Function()? onTapAuthorName;

  /// Callback fired when the "see related quotes" button is tapped.
  final void Function()? onTapSeeQuotes;

  /// Callback fired to toggle author metadata widget size.
  final void Function()? onToggleMetadata;

  /// Author name text style.
  final TextStyle authorNameTextStyle;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "${"author.loading".tr()}...",
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
            onTap: onTapAuthorName,
            child: Padding(
              padding: isMobileSize
                  ? EdgeInsets.only(
                      left: leftPadding,
                      right: rightPadding,
                      bottom: 24.0,
                    )
                  : EdgeInsets.zero,
              child: Hero(
                tag: author.id,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    author.name,
                    style: Utils.calligraphy.title(
                      textStyle: authorNameTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AuthorMetadaColumn(
            author: author,
            isDark: isDark,
            foregroundColor: foregroundColor,
            isOpen: areMetadataOpen,
            onToggleOpen: onToggleMetadata,
            margin: EdgeInsets.only(
              bottom: 24.0,
              left: leftPadding - 6.0,
              right: rightPadding,
            ),
            show: isMobileSize,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: rightPadding,
            ),
            child: AnimatedTextKit(
              isRepeatingAnimation: false,
              displayFullTextOnTap: true,
              animatedTexts: [
                TypewriterAnimatedText(
                  author.summary,
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
          ),
          AuthorMetadaRow(
            author: author,
            foregroundColor: foregroundColor,
            margin: EdgeInsets.only(
              top: 24.0,
              left: leftPadding,
              right: rightPadding,
            ),
            show: !isMobileSize,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                top: 32.0,
                left: leftPadding,
                right: rightPadding,
              ),
              child: TextButton(
                onPressed: onTapSeeQuotes,
                style: TextButton.styleFrom(
                  foregroundColor: randomColor,
                  backgroundColor: randomColor?.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "see_related_quotes".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: isMobileSize ? 16.0 : 24.0,
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
          ).animate().slideY(begin: 0.8, end: 0.0, duration: 250.ms).fadeIn(),
        ]),
      ),
    );
  }
}
