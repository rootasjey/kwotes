import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:screenshot/screenshot.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:wave_divider/wave_divider.dart";

class ShareQuoteTemplate extends StatefulWidget {
  const ShareQuoteTemplate({
    super.key,
    required this.quote,
    required this.textWrapSolution,
    required this.screenshotController,
    this.isMobileSize = false,
    this.isIpad = false,
    this.borderColor,
    this.fabIconData,
    this.fabLabelValue,
    this.margin = EdgeInsets.zero,
    this.onBack,
    this.onTapShareImage,
    this.scrollController,
  });

  /// Whether the screen is mobile.
  final bool isMobileSize;

  /// Whether the screen is iPad.
  final bool isIpad;

  /// Border color from quote's topic.
  final Color? borderColor;

  /// Margin for this widget.
  final EdgeInsets margin;

  /// Callback fired when user taps on back button.
  final void Function()? onBack;

  /// Callback fired when user taps on share button.
  final void Function()? onTapShareImage;

  /// Fab icon data.
  final IconData? fabIconData;

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
  final String? fabLabelValue;

  @override
  State<ShareQuoteTemplate> createState() => _ShareQuoteTemplateState();
}

class _ShareQuoteTemplateState extends State<ShareQuoteTemplate> {
  Color _borderColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry borderRadius = BorderRadius.circular(12.0);
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return FractionallySizedBox(
      widthFactor: widget.isIpad ? 0.6 : 1.0,
      heightFactor: widget.isIpad ? 0.6 : 1.0,
      child: Padding(
        padding: widget.margin,
        child: ListView(
          shrinkWrap: true,
          controller: widget.scrollController,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: widget.onTapShareImage,
                icon: Icon(widget.fabIconData ?? getFabIconData(), size: 18.0),
                label: Text(
                  widget.fabLabelValue ?? getFabLabelValue(),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: _borderColor.computeLuminance() > 0.7
                      ? Colors.black87
                      : _borderColor,
                  textStyle: Utils.calligraphy.body(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: BorderSide(
                      color: _borderColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            Screenshot(
              controller: widget.screenshotController,
              child: Padding(
                padding: widget.isMobileSize
                    ? const EdgeInsets.all(12.0)
                    : const EdgeInsets.all(42.0),
                child: Material(
                  elevation: 6.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: _borderColor,
                      // color: widget.borderColor ?? getTopicColor(context),
                      width: widget.isMobileSize ? 8.0 : 2.0,
                    ),
                    borderRadius: borderRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Stack(
                      children: [
                        Padding(
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
                                  widget.quote.name,
                                  style: widget.textWrapSolution.style,
                                ),
                                if (widget.quote.author.urls.image.isNotEmpty)
                                  BetterAvatar(
                                    radius: 24.0,
                                    imageProvider: NetworkImage(
                                      widget.quote.author.urls.image,
                                    ),
                                    colorFilter: const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    ),
                                    margin: const EdgeInsets.only(top: 24.0),
                                  ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                      top:
                                          widget.quote.author.urls.image.isEmpty
                                              ? 24.0
                                              : 4.0,
                                    ),
                                    child: Text(
                                      widget.quote.author.name,
                                      textAlign: TextAlign.center,
                                      style: Utils.calligraphy.body(),
                                    ),
                                  ),
                                ),
                                if (widget.quote.reference.id.isNotEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 2.0,
                                      ),
                                      child: Text(
                                        widget.quote.reference.name,
                                        textAlign: TextAlign.center,
                                        style: Utils.calligraphy.body(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 16.0,
                          right: 16.0,
                          child: AppIcon(
                            size: 36.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Card border color",
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: foregroundColor?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...Constants.colors.topics
                            .map(
                              (Topic topic) => Material(
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                color: topic.color,
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: InkWell(
                                    onTap: () => onTapColor.call(topic.color),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const WaveDivider(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 64.0,
              ),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: [
                  ActionChip(
                    elevation: 2.0,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            TablerIcons.arrow_back,
                            size: 16.0,
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          "back".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              color: foregroundColor?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: widget.onBack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side: BorderSide(
                        color: foregroundColor?.withOpacity(0.2) ?? Colors.grey,
                        width: 1.2,
                      ),
                    ),
                  ),
                  ActionChip(
                    elevation: 2.0,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(
                            TablerIcons.download,
                            size: 16.0,
                            color: foregroundColor?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    onPressed: widget.onTapShareImage,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side: BorderSide(
                        color: foregroundColor?.withOpacity(0.2) ?? Colors.grey,
                        width: 1.2,
                      ),
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

  /// Get icon data according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  IconData getFabIconData() {
    if (Utils.graphic.isMobile()) {
      return TablerIcons.share;
    }

    return TablerIcons.download;
  }

  /// Get label value according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  String getFabLabelValue() {
    if (Utils.graphic.isMobile()) {
      return "quote.share.image".tr();
    }

    return "download.name".tr();
  }

  /// Returns quote first topic color, if any.
  Color getTopicColor(BuildContext context) {
    if (widget.quote.topics.isEmpty) {
      return Colors.indigo.shade200;
    }

    return Constants.colors.getColorFromTopicName(
      context,
      topicName: widget.quote.topics.first,
    );
  }

  /// Initialize properties.
  void initProps() {
    _borderColor = widget.borderColor ?? getTopicColor(context);
  }

  /// Update quote border color.
  void onTapColor(Color color) {
    setState(() {
      _borderColor = color;
    });
  }
}
