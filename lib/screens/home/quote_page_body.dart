import "package:animated_text_kit/animated_text_kit.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/context_menu_components.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/author.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/reference.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:text_wrap_auto_size/solution.dart";

class QuotePageBody extends StatelessWidget {
  const QuotePageBody({
    super.key,
    required this.quote,
    required this.textWrapSolution,
    required this.userFirestore,
    this.authenticated = false,
    this.pageState = EnumPageState.idle,
    this.onCopyQuote,
    this.onTapAuthor,
    this.onTapReference,
    this.onCopyAuthor,
    this.onCopyReference,
    this.onDoubleTapQuote,
    this.onCopyQuoteUrl,
    this.onCopyAuthorUrl,
    this.onCopyReferenceUrl,
  });

  /// Whether user is authenticated.
  final bool authenticated;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback fired to copy quote's author content.
  final void Function()? onCopyAuthor;

  /// Callback fired to copy quote's reference content.
  final void Function()? onCopyReference;

  /// Callback fired to copy quote's name.
  final void Function()? onCopyQuote;

  /// Callback fired to copy quote's url.
  final void Function()? onCopyQuoteUrl;

  /// Callback fired when author's url is copied.
  final void Function()? onCopyAuthorUrl;

  /// Callback fired when reference's url is copied.
  final void Function()? onCopyReferenceUrl;

  /// Callback fired when author's avatar or name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when reference (if any) is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Callback fired when quote's name is double tapped.
  final void Function()? onDoubleTapQuote;

  /// Quote data for this component.
  final Quote quote;

  /// Indicate text style (font size) for quote's name.
  final Solution textWrapSolution;

  /// User data for this component.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "loading".tr(),
      );
    }

    return Center(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 42.0,
                right: 52.0,
                bottom: 24.0,
              ),
              child: ContextMenuWidget(
                child: GestureDetector(
                  onDoubleTap: onDoubleTapQuote,
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                    pause: const Duration(milliseconds: 0),
                    animatedTexts: [
                      FadeAnimatedText("", duration: 250.ms),
                      TypewriterAnimatedText(
                        quote.name,
                        textStyle: textWrapSolution.style,
                      ),
                    ],
                  ),
                ),
                menuProvider: (MenuRequest request) {
                  return Menu(
                    children: [
                      MenuAction(
                        title: "quote.copy.name".tr(),
                        image: MenuImage.icon(TablerIcons.copy),
                        callback: () => onCopyQuote?.call(),
                      ),
                      MenuAction(
                        title: "quote.copy.url".tr(),
                        image: MenuImage.icon(TablerIcons.link),
                        callback: () => onCopyQuoteUrl?.call(),
                      ),
                      if (authenticated)
                        ContextMenuComponents.addToList(
                          context,
                          quote: quote,
                          userId: userFirestore.id,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (quote.author.urls.image.isNotEmpty)
            SliverToBoxAdapter(
              child: BetterAvatar(
                onTap: onTapAuthor != null
                    ? () => onTapAuthor?.call(quote.author)
                    : null,
                radius: 24.0,
                imageProvider: NetworkImage(
                  quote.author.urls.image,
                ),
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
              ).animate(delay: 250.ms).scale().fadeIn(),
            ),
          SliverToBoxAdapter(
            child: Center(
              child: ContextMenuWidget(
                child: InkWell(
                  onTap: () => onTapAuthor?.call(quote.author),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      quote.author.name,
                      textAlign: TextAlign.center,
                      style: Utils.calligraphy.body(),
                    ),
                  ),
                ),
                menuProvider: (MenuRequest request) {
                  return Menu(
                    children: [
                      MenuAction(
                        title: "author.copy.name".tr(),
                        image: MenuImage.icon(TablerIcons.copy),
                        callback: () => onCopyAuthor?.call(),
                      ),
                      MenuAction(
                        title: "author.copy.url".tr(),
                        image: MenuImage.icon(TablerIcons.link),
                        callback: () => onCopyAuthorUrl?.call(),
                      ),
                    ],
                  );
                },
              ),
            ).animate(delay: 350.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
          ),
          if (quote.reference.id.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: ContextMenuWidget(
                  child: InkWell(
                    onTap: () => onTapReference?.call(quote.reference),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      child: Text(
                        quote.reference.name,
                        textAlign: TextAlign.center,
                        style: Utils.calligraphy.body(),
                      ),
                    ),
                  ),
                  menuProvider: (MenuRequest request) {
                    return Menu(
                      children: [
                        MenuAction(
                          title: "reference.copy.name".tr(),
                          image: MenuImage.icon(TablerIcons.copy),
                          callback: () => onCopyReference?.call(),
                        ),
                        MenuAction(
                          title: "reference.copy.url".tr(),
                          image: MenuImage.icon(TablerIcons.link),
                          callback: () => onCopyReferenceUrl?.call(),
                        ),
                      ],
                    );
                  },
                ),
              ).animate(delay: 600.ms).slideY(begin: 0.8, end: 0.0).fadeIn(),
            ),
        ],
      ),
    );
  }
}
