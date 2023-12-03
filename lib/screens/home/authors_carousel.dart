import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:infinite_carousel/infinite_carousel.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";

class AuthorCarousel extends StatelessWidget {
  /// Author carousel.
  /// Suitable for desktop or large screens.
  ///
  /// See also:
  ///   * [LatestetAddedAuthors]
  const AuthorCarousel({
    super.key,
    required this.authors,
    required this.scrollController,
    this.enableLeftArrow = false,
    this.enableRightArrow = true,
    this.isDark = false,
    this.foregroundColor,
    this.margin = EdgeInsets.zero,
    this.onIndexChanged,
    this.onTapAuthor,
    this.onHoverAuthor,
    this.onTapArrowLeft,
    this.onTapArrowRight,
    this.hoveredAuthorName = "",
    this.itemExtent = 100.0,
  });

  /// Display right arrow if true.
  final bool enableLeftArrow;

  /// Display right arrow if true.
  final bool enableRightArrow;

  /// Whether to use dark theme.
  final bool isDark;

  /// Foreground text color.
  final Color? foregroundColor;

  /// Maximum width for single item in viewport.
  final double itemExtent;

  /// Margin of the widget.
  final EdgeInsets margin;

  /// Callback fired when topic is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when topic is hovered.
  final void Function(Author author, bool isHovered)? onHoverAuthor;

  /// Callback fired when index is changed.
  final void Function(int index)? onIndexChanged;

  /// Callback fired when left arrow is tapped.
  final void Function()? onTapArrowLeft;

  /// Callback fired when right arrow is tapped.
  final void Function()? onTapArrowRight;

  /// List of topics (main data).
  final List<Author> authors;

  /// Current scroll controller.
  final ScrollController scrollController;

  /// Current hovered topic's name.
  final String hoveredAuthorName;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                hoveredAuthorName.isEmpty
                    ? "author.names".tr()
                    : hoveredAuthorName,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: foregroundColor?.withOpacity(0.7),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "author.latest_added".tr(),
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100.0,
              child: InfiniteCarousel.builder(
                center: false,
                loop: false,
                itemCount: authors.length,
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
                itemBuilder: (
                  BuildContext context,
                  int index,
                  int realIndex,
                ) {
                  final Author author = authors[index];
                  final Object image = author.urls.image.isNotEmpty
                      ? NetworkImage(author.urls.image)
                      : const AssetImage(
                          "assets/images/profile-picture-avocado.png");

                  return BetterAvatar(
                    imageProvider: image as ImageProvider,
                    radius: 42.0,
                    margin: const EdgeInsets.only(right: 8.0),
                    onTap: () => onTapAuthor?.call(author),
                    onHover: (bool isHovered) =>
                        onHoverAuthor?.call(author, isHovered),
                    colorFilter: hoveredAuthorName == author.name
                        ? null
                        : const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    onTap: enableLeftArrow ? onTapArrowLeft : null,
                    icon: Icon(
                      TablerIcons.arrow_left,
                      color: enableLeftArrow
                          ? foregroundColor?.withOpacity(0.8)
                          : foregroundColor?.withOpacity(0.2),
                    ),
                  ),
                  Container(
                    height: 6.0,
                    width: 6.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Constants.colors.tertiary,
                    ),
                  ),
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    onTap: enableRightArrow ? onTapArrowRight : null,
                    icon: Icon(
                      TablerIcons.arrow_right,
                      color: enableRightArrow
                          ? foregroundColor?.withOpacity(0.8)
                          : foregroundColor?.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
