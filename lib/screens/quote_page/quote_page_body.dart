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
    this.selectedColor,
    this.pageState = EnumPageState.idle,
    this.onChangeLanguage,
    this.onCopyQuote,
    this.onCopyQuoteUrl,
    this.onCopyAuthorUrl,
    this.onCopyReferenceUrl,
    this.onCopyAuthor,
    this.onCopyReference,
    this.onDeleteQuote,
    this.onDoubleTapQuote,
    this.onEditQuote,
    this.onShareImage,
    this.onShareLink,
    this.onShareText,
    this.onTapAuthor,
    this.onTapReference,
    this.windowSize = const Size(0.0, 0.0),
  });

  /// Whether user is authenticated.
  final bool authenticated;

  /// Selected list color.
  final Color? selectedColor;

  /// Page's state (e.g. loading, idle, ...).
  final EnumPageState pageState;

  /// Callback fired when a new language is selected the quote.
  final void Function(Quote quote, String language)? onChangeLanguage;

  /// Callback fired to copy quote's author content.
  final void Function(Author author)? onCopyAuthor;

  /// Callback fired when author's url is copied.
  final void Function(Author author)? onCopyAuthorUrl;

  /// Callback fired to copy quote's name.
  final void Function(Quote quote)? onCopyQuote;

  /// Callback fired to copy quote's url.
  final void Function(Quote quote)? onCopyQuoteUrl;

  /// Callback fired to copy quote's reference content.
  final void Function()? onCopyReference;

  /// Callback fired when reference's url is copied.
  final void Function()? onCopyReferenceUrl;

  /// Callback fired when quote is deleted.
  final void Function(Quote)? onDeleteQuote;

  /// Callback fired when quote's name is double tapped.
  final void Function(Quote quote)? onDoubleTapQuote;

  /// Callback fired when quote is edited.
  final void Function(Quote)? onEditQuote;

  /// Callback fired when image is shared.
  final void Function(Quote quote)? onShareImage;

  /// Callback fired when link is shared.
  final void Function(Quote quote)? onShareLink;

  /// Callback fired when text is shared.
  final void Function(Quote quote)? onShareText;

  /// Callback fired when author's avatar or name is tapped.
  final void Function(Author author)? onTapAuthor;

  /// Callback fired when reference (if any) is tapped.
  final void Function(Reference reference)? onTapReference;

  /// Quote data for this component.
  final Quote quote;

  /// Window size for this component.
  final Size windowSize;

  /// Indicate text style (font size) for quote's name.
  final Solution textWrapSolution;

  /// User data for this component.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    if (pageState == EnumPageState.loading) {
      return LoadingView(
        message: "loading".tr(),
        useSliver: false,
      );
    }

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    double bottomPadding = 0.0;
    if (windowSize.width < 600 && windowSize.height >= 500) {
      bottomPadding = 48.0;
    } else if (windowSize.width > 1000) {
      bottomPadding = 12.0;
    }

    return Center(
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: 24.0,
                left: 42.0,
                right: 42.0,
                bottom: bottomPadding,
              ),
              child: ContextMenuWidget(
                child: GestureDetector(
                  onDoubleTap: () => onDoubleTapQuote?.call(quote),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                    pause: const Duration(milliseconds: 0),
                    animatedTexts: [
                      FadeAnimatedText("", duration: 250.ms),
                      TypewriterAnimatedText(
                        quote.name,
                        speed: 10.ms,
                        textStyle: textWrapSolution.style,
                      ),
                    ],
                  ),
                ),
                menuProvider: (MenuRequest menuRequest) =>
                    ContextMenuComponents.quoteMenuProvider(
                  context,
                  quote: quote,
                  onCopyQuote: onCopyQuote,
                  onCopyQuoteUrl: onCopyQuoteUrl,
                  selectedColor: selectedColor,
                  onChangeLanguage: onChangeLanguage,
                  onDelete: onDeleteQuote,
                  onEdit: onEditQuote,
                  onShareImage: onShareImage,
                  onShareLink: onShareLink,
                  onShareText: onShareText,
                  userId: userFirestore.id,
                ),
              ),
            ),
          ),
          if (quote.author.urls.image.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
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
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          color: foregroundColor?.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
                menuProvider: (MenuRequest request) =>
                    ContextMenuComponents.authorMenuProvider(
                  context,
                  author: quote.author,
                  onCopyAuthor: onCopyAuthor,
                  onCopyAuthorUrl: onCopyAuthorUrl,
                ),
              ),
            )
                .animate(delay: 350.ms)
                .slideY(
                  begin: 0.2,
                  end: 0.0,
                  duration: const Duration(milliseconds: 75),
                  curve: Curves.decelerate,
                )
                .fadeIn(),
          ),
          if (quote.reference.id.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: ContextMenuWidget(
                  child: InkWell(
                    onTap: () => onTapReference?.call(quote.reference),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2.0,
                      ),
                      child: Text(
                        quote.reference.name,
                        textAlign: TextAlign.center,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
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
              )
                  .animate(delay: 500.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0.0,
                    duration: const Duration(milliseconds: 75),
                    curve: Curves.decelerate,
                  )
                  .fadeIn(),
            ),
        ],
      ),
    );
  }
}
