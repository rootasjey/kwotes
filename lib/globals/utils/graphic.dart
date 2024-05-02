import "dart:io";

import "package:bottom_sheet/bottom_sheet.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:image_downloader_web/image_downloader_web.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/actions/quote_actions.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_dialog.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/quote_page/share_quote_template.dart";
import "package:kwotes/types/enums/enum_color_value_type.dart";
import "package:kwotes/types/enums/enum_main_genre.dart";
import "package:kwotes/types/enums/enum_snackbar_type.dart";
import "package:kwotes/types/enums/enum_topic.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:share_plus/share_plus.dart";
import "package:text_wrap_auto_size/solution.dart";
import "package:text_wrap_auto_size/text_wrap_auto_size.dart";

/// Graphic utilities (everything associated with visual and UI).
class Graphic with UiLoggy {
  const Graphic();

  double getDesktopPadding() {
    if (!Utils.graphic.isMobile()) {
      return 36.0;
    }

    return 0.0;
  }

  /// Return the color based on the content type.
  Color getSnackbarColorType(SnackbarType type) {
    switch (type) {
      case SnackbarType.info:
        return Colors.blue.shade100;

      case SnackbarType.success:
        return Colors.green.shade100;

      case SnackbarType.error:
        return Colors.red.shade100;

      case SnackbarType.warning:
        return Colors.yellow.shade100;

      default:
        return Colors.blue.shade100;
    }
  }

  /// Get icon data from a primary genre.
  IconData getIconDataFromGenre(EnumMainGenre genre) {
    switch (genre) {
      case EnumMainGenre.book:
      case EnumMainGenre.novel:
        return TablerIcons.book_2;
      case EnumMainGenre.film:
      case EnumMainGenre.tv_series:
        return TablerIcons.movie;
      case EnumMainGenre.music:
        return TablerIcons.music;
      case EnumMainGenre.painting:
      case EnumMainGenre.photo:
        return TablerIcons.camera_selfie;
      case EnumMainGenre.bd:
      case EnumMainGenre.comic:
      case EnumMainGenre.graphic_novel:
        return TablerIcons.photo;
      case EnumMainGenre.game:
      case EnumMainGenre.video_game:
        return TablerIcons.device_gamepad;
      case EnumMainGenre.video:
        return TablerIcons.device_tv;
      case EnumMainGenre.podcast:
        return TablerIcons.microphone;
      case EnumMainGenre.website:
        return TablerIcons.globe;
      case EnumMainGenre.article:
      case EnumMainGenre.news:
      case EnumMainGenre.post:
      case EnumMainGenre.blog:
        return TablerIcons.news;
      case EnumMainGenre.play:
        return TablerIcons.masks_theater;
      default:
        return TablerIcons.question_mark;
    }
  }

  /// Get icon data from a topic string.
  IconData getIconDataFromTopic(String topic) {
    if (topic == EnumTopic.art.name) {
      return TablerIcons.brush;
    }
    if (topic == EnumTopic.biology.name) {
      return TablerIcons.dna;
    }
    if (topic == EnumTopic.feelings.name) {
      return TablerIcons.heart;
    }
    if (topic == EnumTopic.fun.name) {
      return TablerIcons.confetti;
    }
    if (topic == EnumTopic.gratitude.name) {
      return TablerIcons.heart_handshake;
    }
    if (topic == EnumTopic.introspection.name) {
      return TablerIcons.eye_closed;
    }
    if (topic == EnumTopic.knowledge.name) {
      return TablerIcons.square_root;
    }
    if (topic == EnumTopic.language.name) {
      return TablerIcons.language;
    }
    if (topic == EnumTopic.mature.name) {
      return TablerIcons.explicit;
    }
    if (topic == EnumTopic.metaphor.name) {
      return TablerIcons.rainbow;
    }
    if (topic == EnumTopic.motivation.name) {
      return TablerIcons.flare;
    }
    if (topic == EnumTopic.offensive.name) {
      return TablerIcons.dental;
    }
    if (topic == EnumTopic.philosophy.name) {
      return TablerIcons.yoga;
    }
    if (topic == EnumTopic.poetry.name) {
      return TablerIcons.writing;
    }
    if (topic == EnumTopic.psychology.name) {
      return TablerIcons.brain;
    }
    if (topic == EnumTopic.proverb.name) {
      return TablerIcons.cane;
    }
    if (topic == EnumTopic.punchline.name) {
      return TablerIcons.sunglasses;
    }
    if (topic == EnumTopic.retrospection.name) {
      return TablerIcons.eye;
    }
    if (topic == EnumTopic.sciences.name) {
      return TablerIcons.microscope;
    }
    if (topic == EnumTopic.social.name) {
      return TablerIcons.friends;
    }
    if (topic == EnumTopic.spiritual.name) {
      return TablerIcons.ghost;
    }
    if (topic == EnumTopic.travel.name) {
      return TablerIcons.air_balloon;
    }
    if (topic == EnumTopic.work.name) {
      return TablerIcons.gavel;
    }

    return TablerIcons.question_mark;
  }

  /// Get the color value type suffix (for translation).
  String getColorValueTypeSuffix(EnumColorValueType colorValueType) {
    switch (colorValueType) {
      case EnumColorValueType.value:
        return "value";
      case EnumColorValueType.hex:
        return "hex";
      case EnumColorValueType.rgba:
        return "rgba";
      default:
        return "default";
    }
  }

  /// Get the snackbar width according to the passed text.
  double? getSnackWidth(String str) {
    if (str.isEmpty) {
      return null;
    }

    if (str.length < 10) {
      return 260.0;
    }

    if (str.length < 30) {
      return 310.0;
    }

    if (str.length < 50) {
      return 360.0;
    }

    return null;
  }

  /// Get the snackbar width according to the passed text length.
  double? getSnackWidthFromLength(int length) {
    if (length == 0) {
      return null;
    }

    if (length < 10) {
      return 260.0;
    }

    if (length < 30) {
      return 310.0;
    }

    if (length < 40) {
      return 360.0;
    }

    if (length < 50) {
      return 440.0;
    }

    if (length < 60) {
      return 500.0;
    }

    return null;
  }

  /// Return true if the current platform is Android.
  bool isAndroid() {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid;
  }

  /// Return true if the current platform is mobile (e.g. Android or iOS).
  bool isMobile() {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid || Platform.isIOS;
  }

  /// Return true if the current platform is iPad.
  Future<bool> isIpad() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo info = await deviceInfo.iosInfo;
      if (info.model.toLowerCase().contains("ipad")) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Show a dialog or a modal bottom sheet according to `isMobileSize` value.
  Future showAdaptiveDialog(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isMobileSize = false,
    Color? backgroundColor,
  }) {
    if (isMobileSize) {
      // showFlexibleBottomSheet(
      //   context: context,
      //   minHeight: 0.0,
      //   initHeight: 0.5,
      //   maxHeight: 0.9,
      //   anchors: [0.0, 0.9],
      //   bottomSheetBorderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(12.0),
      //     topRight: Radius.circular(12.0),
      //   ),
      //   builder: (
      //     BuildContext context,
      //     scrollController,
      //     bottomSheetOffset,
      //   ) {
      //     return builder;
      //     // return AddToListDialog(
      //     //   asBottomSheet: isMobileSize,
      //     //   autofocus: autofocus,
      //     //   startInCreate: startInCreate,
      //     //   userId: userId,
      //     //   quotes: quotes,
      //     //   scrollController: scrollController,
      //     //   selectedColor: selectedColor,
      //     // );
      //   },
      // );
      return showModalBottomSheet(
        context: context,
        builder: builder,
        isDismissible: true,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: backgroundColor,
        clipBehavior: Clip.hardEdge,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 24.0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
      );
    }

    return showDialog(
      context: context,
      builder: builder,
    );
  }

  /// Show snackbar indicating that a color has been successfully copied.
  void showCopyColorSnackbar(
    BuildContext context, {
    required Topic topic,
    bool isMobileSize = false,
    EnumColorValueType valueType = EnumColorValueType.value,
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final Color backgroundColor = Theme.of(context).dialogBackgroundColor;

    final String topicName = " ${topic.name} ";
    final String suffix = getColorValueTypeSuffix(valueType);
    final String successMessage =
        " ${"color.copy.success.$suffix".tr().toLowerCase()}";
    double? width;

    if (!isMobileSize) {
      final int stringLength = topicName.length + successMessage.length;
      width = getSnackWidthFromLength(stringLength);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text.rich(
          TextSpan(
            text: topicName,
            children: [
              TextSpan(
                text: successMessage,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w400,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 14.0,
              color: topic.color.computeLuminance() > 0.4
                  ? Colors.black
                  : Colors.white,
              fontWeight: FontWeight.w600,
              backgroundColor: topic.color,
            ),
          ),
        ),
        width: width,
        showCloseIcon: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide(color: topic.color, width: 4.0),
        ),
        backgroundColor: backgroundColor,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        behavior:
            isMobileSize ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a snackbar.
  void showSnackbar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    SnackbarType type = SnackbarType.error,
    SnackBarBehavior? behavior,
    double? width,
    Duration duration = const Duration(seconds: 4),
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color defaultBackgroundColor =
        Theme.of(context).dialogBackgroundColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(
          message,
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 14.0,
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        width: width,
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide(color: getSnackbarColorType(type), width: 4.0),
        ),
        backgroundColor: backgroundColor ?? defaultBackgroundColor,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        behavior: behavior,
      ),
    );
  }

  /// Show a copy quote name snackbar.
  void showCopyQuoteSnackbar(
    BuildContext context, {
    bool isMobileSize = false,
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color defaultBackgroundColor =
        Theme.of(context).dialogBackgroundColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(TablerIcons.copy),
            ),
            Text(
              "quote.copy.success.name".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        width: isMobileSize ? null : 600.0,
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide(color: Constants.colors.home, width: 4.0),
        ),
        backgroundColor: defaultBackgroundColor,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        behavior: isMobileSize ? null : SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a copy quote url snackbar.
  void showCopyQuoteLinkSnackbar(
    BuildContext context, {
    bool isMobileSize = false,
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color defaultBackgroundColor =
        Theme.of(context).dialogBackgroundColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(TablerIcons.link),
            ),
            Text(
              "quote.copy.success.link".tr(),
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        width: isMobileSize ? null : 600.0,
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide(color: Constants.colors.home, width: 4.0),
        ),
        backgroundColor: defaultBackgroundColor,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        behavior: isMobileSize ? null : SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a snackbar with custom text.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackbarWithCustomText(
    BuildContext context, {
    required Widget text,
    bool showCloseIcon = true,
    ShapeBorder? shape,
    SnackBarBehavior? behavior,
    Duration duration = const Duration(seconds: 4),
    double? width,
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color backgroundColor = Theme.of(context).dialogBackgroundColor;

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: behavior,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        content: text,
        duration: duration,
        shape: shape,
        showCloseIcon: showCloseIcon,
        width: width,
      ),
    );
  }

  /// Show an add to list dialog.
  Future showAddToListDialog(
    BuildContext context, {
    required List<Quote> quotes,
    required String userId,
    bool autofocus = false,
    bool isMobileSize = false,
    bool startInCreate = false,
    bool isIpad = false,

    /// Selected list color.
    Color? selectedColor,
  }) {
    if (isMobileSize) {
      return showFlexibleBottomSheet(
        context: context,
        minHeight: 0.0,
        initHeight: 0.5,
        maxHeight: 0.9,
        anchors: [0.0, 0.9],
        bottomSheetBorderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        builder: (
          BuildContext context,
          scrollController,
          bottomSheetOffset,
        ) {
          return AddToListDialog(
            asBottomSheet: isMobileSize,
            autofocus: autofocus,
            isIpad: isIpad,
            startInCreate: startInCreate,
            userId: userId,
            quotes: quotes,
            scrollController: scrollController,
            selectedColor: selectedColor ?? Constants.colors.lists,
          );
        },
      );
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) => AddToListDialog(
        asBottomSheet: isMobileSize,
        autofocus: autofocus,
        selectedColor: selectedColor ?? Constants.colors.lists,
        startInCreate: startInCreate,
        userId: userId,
        quotes: quotes,
      ),
    );
  }

  /// Get text solution (style) based on window size.
  Solution getTextSolution({
    required Quote quote,
    required Size windowSize,
    double? minFontSize,
    double? maxFontSize,
    TextStyle? style,
  }) {
    const double paddingValue = 54.0;
    Size quoteContainerSize = const Size(0.0, 0.0);

    if (NavigationStateHelper.isIpad) {
      quoteContainerSize = Size(
        (windowSize.width * 0.7) - paddingValue,
        (windowSize.height * 0.5) - paddingValue,
      );
    }

    quoteContainerSize = Size(
      (windowSize.width * 0.7) - paddingValue,
      (windowSize.height * 0.6) - paddingValue,
    );

    try {
      return TextWrapAutoSize.solution(
        quoteContainerSize,
        Text(quote.name, style: style),
        minFontSize: minFontSize,
        maxFontSize: maxFontSize,
      );
    } catch (e) {
      loggy.error(e);
      double manualFontSize = 18.0;

      return Solution(
        Text(quote.name),
        Utils.calligraphy.body(
          textStyle: TextStyle(
            fontSize: manualFontSize,
          ),
        ),
        quoteContainerSize,
        windowSize,
      );
    }
  }

  /// Callback fired to capture image and share it on mobile device,
  /// or download it on other platforms.
  /// [pop] if true, execute additional pop
  /// (to close previous bottom sheet on mobile).
  void onCaptureImage(
    BuildContext context, {
    required ScreenshotController screenshotController,
    required Quote quote,
    bool mounted = false,
    bool pop = false,
  }) {
    screenshotController.capture().then((Uint8List? image) async {
      if (image == null) {
        return;
      }

      if (Utils.graphic.isMobile()) {
        Share.shareXFiles(
          [
            XFile.fromData(
              image,
              name: "${_generateFileName(quote)}.png",
              mimeType: "image/png",
            ),
          ],
          sharePositionOrigin: const Rect.fromLTWH(12, 12, 12, 12),
        );
        return;
      }

      if (kIsWeb) {
        await WebImageDownloader.downloadImageFromUInt8List(
          uInt8List: image,
          imageQuality: 1.0,
          name: "${_generateFileName(quote)}.png",
        );
        return;
      }

      final String? prefix = await FilePicker.platform.getDirectoryPath();

      if (prefix == null) {
        loggy.info("`prefix` is null probably because the user cancelled. "
            "Download cancelled.");

        if (!mounted) return;
        Utils.graphic.showSnackbar(
          context,
          message: "download.error.cancelled".tr(),
        );
        return;
      }

      final String path = "$prefix/${_generateFileName(quote)}.png";
      await File(path).writeAsBytes(image);
      if (!mounted) return;

      Utils.graphic.showSnackbar(
        context,
        message: "download.success".tr(),
      );

      if (pop) {
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      loggy.error(error);
      Utils.graphic.showSnackbar(
        context,
        message: "download.failed".tr(),
      );
    }).whenComplete(() => Navigator.of(context).pop());
  }

  /// Callback fired to share quote as image.
  /// [pop] indicates if a bottom sheet should be popped after sharing.
  void onOpenShareImage(
    BuildContext context, {
    required Quote quote,
    required ScreenshotController screenshotController,
    required Solution textWrapSolution,
    bool mounted = false,
    bool pop = false,
  }) {
    showFlexibleBottomSheet(
      context: context,
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: 0.9,
      anchors: [0.0, 0.9],
      bottomSheetBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12.0),
        topRight: Radius.circular(12.0),
      ),
      builder: (
        BuildContext context,
        ScrollController scrollController,
        double bottomSheetOffset,
      ) {
        return ShareQuoteTemplate(
          quote: quote,
          isMobileSize: Utils.measurements.isMobileSize(context),
          screenshotController: screenshotController,
          textWrapSolution: textWrapSolution,
          onBack: Navigator.of(context).pop,
          onTapShareImage: () => Utils.graphic.onCaptureImage(
            context,
            mounted: mounted,
            pop: pop,
            quote: quote,
            screenshotController: screenshotController,
          ),
          scrollController: scrollController,
          margin: const EdgeInsets.only(top: 24.0),
        );
      },
    );
  }

  /// Callback fired to share quote as link.
  void onShareLink(BuildContext context, {required Quote quote}) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      QuoteActions.copyQuoteUrl(quote);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.copy_link.success".tr(),
      );
      return;
    }

    if (Utils.graphic.isMobile()) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      Share.share(
        "${Constants.quoteUrl}/${quote.id}",
        subject: "quote.name".tr(),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      return;
    }
  }

  /// Callback fired to share quote as text.
  void onShareText(
    BuildContext context, {
    required Quote quote,
    void Function(Quote quote)? onCopyQuote,
  }) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      onCopyQuote?.call(quote);
      return;
    }

    String textToShare = "«$quote.name}»";

    if (quote.author.name.isNotEmpty) {
      textToShare += " — ${quote.author.name}";
    }

    if (quote.reference.name.isNotEmpty) {
      textToShare += " — ${quote.reference.name}";
    }

    if (Utils.graphic.isMobile()) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      Share.share(
        textToShare,
        subject: "quote.name".tr(),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      return;
    }
  }

  /// Generate file name for image to save on device.
  String _generateFileName(Quote quote) {
    String name = "quote.name".tr();

    if (quote.author.name.isNotEmpty) {
      name += " — ${quote.author.name}";
    }

    if (quote.reference.name.isNotEmpty) {
      name += " — ${quote.reference.name}";
    }

    return name;
  }

  /// Wrap a widget with a tooltip.
  Widget tooltip({
    required Widget child,
    required String tooltipString,
    Color? backgroundColor,
  }) {
    if (tooltipString.isEmpty) {
      return child;
    }

    return JustTheTooltip(
      tailLength: 4.0,
      tailBaseWidth: 12.0,
      backgroundColor: backgroundColor,
      waitDuration: const Duration(seconds: 1),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          tooltipString,
          style: Utils.calligraphy.body(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      child: child,
    );
  }

  /// Add quote app bar.
  PreferredSizeWidget addQuoteAppBar(
    BuildContext context, {
    bool hasHistory = false,
    bool isMobileSize = false,
    Color? foregroundColor,
    void Function()? onTapAppIcon,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Row(
          children: [
            if (hasHistory)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleButton.outlined(
                  borderColor: Colors.transparent,
                  onTap: () => Utils.passage.back(
                    context,
                    isMobile: isMobileSize,
                  ),
                  child: Icon(
                    TablerIcons.arrow_left,
                    color: foregroundColor?.withOpacity(0.8),
                    size: 22.0,
                  ),
                ),
              ),
            AppIcon(
              size: 24.0,
              onTap: onTapAppIcon,
            ),
          ],
        ),
      ),
      bottom: TabBar(
        tabs: [
          Tab(text: "content.name".tr()),
          Tab(text: "topics.name".tr()),
          Tab(text: "author.name".tr()),
          Tab(text: "reference.name".tr()),
        ],
      ),
    );
  }
}
