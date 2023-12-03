import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/buttons/colored_text_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";

class ShareQuoteTemplate extends StatelessWidget {
  const ShareQuoteTemplate({
    super.key,
    required this.quote,
    required this.textWrapSolution,
    required this.borderColor,
    required this.screenshotController,
    required this.fabLabelValue,
    required this.fabIconData,
    this.isMobileSize = false,
    this.backgroundColor = Colors.white70,
    this.margin = EdgeInsets.zero,
    this.onBack,
    this.onTapShareImage,
    this.scrollController,
  });

  /// Whether the screen is mobile.
  final bool isMobileSize;

  /// Border radius for this widget.
  final Color backgroundColor;

  /// Border color from quote's topic.
  final Color borderColor;

  /// Margin for this widget.
  final EdgeInsets margin;

  /// Callback fired when user taps on back button.
  final void Function()? onBack;

  /// Callback fired when user taps on share button.
  final void Function()? onTapShareImage;

  /// Fab icon data.
  final IconData fabIconData;

  /// Quote data.
  final Quote quote;

  /// Screenshot controller.
  final ScreenshotController screenshotController;

  /// Scroll controller.
  final ScrollController? scrollController;

  /// Indicate text style (font size) for quote's name.
  final Solution textWrapSolution;

  /// String label value according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  final String fabLabelValue;

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry borderRadius = BorderRadius.circular(12.0);

    return Padding(
      padding: margin,
      child: ListView(
        shrinkWrap: true,
        controller: scrollController,
        children: [
          ColoredTextButton(
            accentColor: borderColor,
            textValue: fabLabelValue,
            onPressed: onTapShareImage,
            icon: Icon(fabIconData),
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
          ),
          Screenshot(
            controller: screenshotController,
            child: Padding(
              padding: isMobileSize
                  ? const EdgeInsets.all(12.0)
                  : const EdgeInsets.all(42.0),
              child: Material(
                elevation: 6.0,
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: borderColor,
                    width: isMobileSize ? 8.0 : 2.0,
                  ),
                  borderRadius: borderRadius,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(42.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 300.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            quote.name,
                            style: textWrapSolution.style,
                          ),
                          if (quote.author.urls.image.isNotEmpty)
                            BetterAvatar(
                              radius: 24.0,
                              imageProvider: NetworkImage(
                                quote.author.urls.image,
                              ),
                              colorFilter: const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                              margin: const EdgeInsets.only(top: 24.0),
                            ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                quote.author.name,
                                textAlign: TextAlign.center,
                                style: Utils.calligraphy.body(),
                              ),
                            ),
                          ),
                          if (quote.reference.id.isNotEmpty)
                            Center(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ColoredTextButton(
            accentColor: borderColor,
            textValue: "back".tr(),
            onPressed: onBack,
            icon: const Icon(TablerIcons.arrow_back),
            margin: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}