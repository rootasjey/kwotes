import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/home/reference_poster.dart";
import "package:kwotes/types/reference.dart";

class ReferencePosters extends StatelessWidget {
  const ReferencePosters({
    super.key,
    required this.scrollController,
    this.isDark = false,
    this.backgroundColor,
    this.textColor,
    this.itemExtent = 260.0,
    this.margin = EdgeInsets.zero,
    this.onTapReference,
    this.onIndexChanged,
    this.references = const [],
  });

  /// Whether to use dark theme.
  final bool isDark;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground text color.
  final Color? textColor;

  /// Item extent.
  final double itemExtent;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when reference is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback fired when index is changed.
  final void Function(int index)? onIndexChanged;

  /// Scroll controller.
  final InfiniteScrollController scrollController;

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
      child: Container(
        padding: margin,
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "reference.latest_added".tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: textColor?.withOpacity(0.4),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 360.0,
              child: InfiniteCarousel.builder(
                center: true,
                itemCount: references.length,
                itemExtent: itemExtent,
                controller: scrollController,
                onIndexChanged: onIndexChanged,
                scrollBehavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.invertedStylus,
                  },
                ),
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  final Reference reference = references[index];

                  final double currentOffset = itemExtent * realIndex;
                  final double diff = (scrollController.offset - currentOffset);
                  const double maxPadding = 24.0;
                  final double carouselRatio = itemExtent / maxPadding;
                  final bool selected = index == scrollController.selectedItem;

                  return ReferencePoster(
                    selected: selected,
                    margin: EdgeInsets.only(
                      top: selected ? 0.0 : (diff / carouselRatio).abs(),
                      bottom: selected ? 0.0 : (diff / carouselRatio).abs(),
                    ),
                    onTap: onTapReference,
                    reference: reference,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
