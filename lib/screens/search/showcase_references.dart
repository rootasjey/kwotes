import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:kwotes/components/texts/showcase_text.dart";
import "package:kwotes/types/reference.dart";
import "package:wave_divider/wave_divider.dart";

class ShowcaseReferences extends StatelessWidget {
  const ShowcaseReferences({
    super.key,
    this.animateItemList = false,
    this.isDark = false,
    this.isMobileSize = false,
    this.margin = EdgeInsets.zero,
    this.references = const [],
    this.onTapReference,
  });

  /// Animate item if true.
  /// Used to skip animation while scrolling.
  final bool animateItemList;

  /// Whether dark theme is active.
  final bool isDark;

  /// Adapt UI to mobile size.
  final bool isMobileSize;

  /// Space around this widget.
  final EdgeInsets margin;

  /// List of authors.
  final List<Reference> references;

  /// Callback fired when reference name is tapped.
  final void Function(Reference reference)? onTapReference;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverPadding(
      padding: margin,
      sliver: SliverList.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: WaveDivider(
              waveHeight: 2.0,
              waveWidth: 5.0,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.2),
            ),
          )
              .animate(
                delay:
                    animateItemList ? Duration(milliseconds: 25 * index) : null,
              )
              .fadeIn(
                duration: Duration(milliseconds: 25 * index),
                curve: Curves.decelerate,
              )
              .slideY(
                begin: 0.4,
                end: 0.0,
              );
        },
        itemBuilder: (BuildContext context, int index) {
          final Reference reference = references[index];

          ImageProvider? imageProvider =
              const AssetImage("assets/images/profile-picture-carrot.png");
          if (reference.urls.image.isNotEmpty) {
            imageProvider = NetworkImage(reference.urls.image);
          }

          return ShowcaseText(
            docId: reference.id,
            isDark: isDark,
            index: index,
            useSquareAvatar: true,
            imageProvider: imageProvider,
            subtitleValue: "genre.primary".tr(gender: reference.type.primary),
            initialForegroundColor: foregroundColor?.withOpacity(0.8),
            isMobileSize: isMobileSize,
            onTap: onTapReference != null
                ? () => onTapReference?.call(reference)
                : null,
            textValue: reference.name,
          )
              .animate(
                delay:
                    animateItemList ? Duration(milliseconds: 25 * index) : null,
              )
              .fadeIn(
                duration: 125.ms,
                curve: Curves.decelerate,
              )
              .slideY(
                begin: 0.4,
                end: 0.0,
              );
        },
        itemCount: references.length,
      ),
    );
  }
}
