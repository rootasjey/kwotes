import "dart:io";

import "package:bottom_sheet/bottom_sheet.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/quote_page/share_quote_template.dart";
import "package:kwotes/types/enums/enum_draft_quote_operation.dart";
import "package:kwotes/types/firestore/document_snapshot_map.dart";
import "package:kwotes/types/quote.dart";
import "package:loggy/loggy.dart";
import "package:screenshot/screenshot.dart";
import "package:share_plus/share_plus.dart";
import "package:text_wrap_auto_size/solution.dart";

class QuoteActions {
  /// Add quote to an user's favourites
  static Future<bool> addToFavourites({
    required Quote quote,
    required userId,
  }) async {
    try {
      final DocumentSnapshotMap existingDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .get();

      if (existingDoc.exists) {
        return true;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .set(quote.toMapFavourite());

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Copy a quote to clipboard.
  static void copyQuote(Quote quote) {
    String textToCopy = "«${quote.name}»";

    if (quote.author.name.isNotEmpty) {
      textToCopy += " — ${quote.author.name}";
    }

    if (quote.reference.name.isNotEmpty) {
      textToCopy += " — ${quote.reference.name}";
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
  }

  /// Copy a quote's url to clipboard.
  static void copyQuoteUrl(Quote quote) {
    Clipboard.setData(ClipboardData(text: "${Constants.quoteUrl}/${quote.id}"));
  }

  /// Remove a quote from an user's favourites
  static Future<bool> removeFromFavourites({
    required Quote quote,
    required userId,
  }) async {
    try {
      final existingDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .get();

      if (!existingDoc.exists) {
        return true;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favourites")
          .doc(quote.id)
          .delete();

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Generate file name for image to save on device.
  static String generateFileName(Quote quote) {
    String name = "quote.name".tr();

    if (quote.author.name.isNotEmpty) {
      name += " — ${quote.author.name}";
    }

    if (quote.reference.name.isNotEmpty) {
      name += " — ${quote.reference.name}";
    }

    return "$name.png";
  }

  /// Callback fired to capture image and share it on mobile device,
  /// or download it on other platforms.
  /// [pop] if true, execute additional pop
  /// (to close previous bottom sheet on mobile).
  static Future<bool> captureImage(
    BuildContext context, {
    required ScreenshotController screenshotController,
    required String filename,
    bool pop = false,
    Loggy<UiLoggy>? loggy,
    void Function()? onPop,
  }) {
    return screenshotController.capture().then((Uint8List? image) async {
      if (image == null) {
        return false;
      }

      if (Utils.graphic.isMobile()) {
        Share.shareXFiles(
          [
            XFile.fromData(
              image,
              name: filename,
              mimeType: "image/png",
            ),
          ],
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 0, 0),
        );
        return true;
      }

      final String? prefix = await FilePicker.platform.getDirectoryPath();

      if (prefix == null) {
        loggy?.info("`prefix` is null probably because the user cancelled. "
            "Download cancelled.");
        return false;
      }

      final String path = "$prefix/$filename";
      await File(path).writeAsBytes(image);

      if (onPop != null) {
        onPop.call();
      }

      return true;
    }).catchError((error) {
      loggy?.error(error);
      Utils.graphic.showSnackbar(
        context,
        message: "download.failed".tr(),
      );

      return false;
    }).whenComplete(() => Navigator.of(context).pop());
  }

  /// Get label value according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  static String getShareFabLabelValue() {
    if (Utils.graphic.isMobile()) {
      return "quote.share.image".tr();
    }

    return "download.name".tr();
  }

  /// Get icon data according to the current platform.
  /// e.g. "Share" for Android, iOS. "Download" for other platforms.
  static IconData getShareFabIconData() {
    if (Utils.graphic.isMobile()) {
      return TablerIcons.share;
    }

    return TablerIcons.download;
  }

  /// Returns the height padding for this widget according to available data
  /// (e.g. author, reference).
  static double getShareHeightPadding(Quote quote) {
    double heightPadding = 158.0;

    if (quote.author.name.isNotEmpty) {
      heightPadding += 24.0;
    }

    if (quote.author.urls.image.isNotEmpty) {
      heightPadding += 54.0;
    }

    if (quote.reference.name.isNotEmpty) {
      heightPadding += 24.0;
    }

    return heightPadding;
  }

  /// Propose quote as draft in the global "drafts" collection.
  /// The result of this operation is silent as it doesn't use context.
  static void proposeQuote({
    required Quote quote,
    required String userId,
  }) async {
    if (userId.isEmpty ||
        quote.name.isEmpty ||
        quote.name.length < 3 ||
        quote.topics.isEmpty) {
      return;
    }

    final Map<String, dynamic> map = quote.toMap(
      userId: userId,
      operation: EnumQuoteOperation.create,
    );

    final DocumentSnapshot draft = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("drafts")
        .doc(quote.id)
        .get();

    if (!draft.exists) return; // in case of duplicate action
    await FirebaseFirestore.instance.collection("drafts").add(map);
    await draft.reference.delete();
  }

  /// Callback fired to share quote as image.
  /// [pop] indicates if a bottom sheet should be popped after sharing.
  static void shareQuoteImage(
    BuildContext context, {
    required Color borderColor,
    required Quote quote,
    required ScreenshotController screenshotController,
    required Solution textWrapSolution,
    void Function({bool pop})? onCaptureImage,
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
          borderColor: borderColor,
          fabIconData: getShareFabIconData(),
          fabLabelValue: getShareFabLabelValue(),
          isMobileSize: Utils.measurements.isMobileSize(context),
          margin: const EdgeInsets.only(top: 24.0),
          onBack: Navigator.of(context).pop,
          onTapShareImage: () => onCaptureImage?.call(pop: pop),
          quote: quote,
          screenshotController: screenshotController,
          scrollController: scrollController,
          textWrapSolution: textWrapSolution,
        );
      },
    );
  }

  /// Callback fired to share quote as link.
  static void shareQuoteLink(BuildContext context, Quote quote) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      QuoteActions.copyQuoteUrl(quote);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.copy_link.success".tr(),
      );
      return;
    }

    if (Utils.graphic.isMobile()) {
      Share.shareUri(Uri.parse("${Constants.quoteUrl}/${quote.id}"));
      return;
    }
  }

  /// Share a quote name.
  static void shareQuoteText(BuildContext context, Quote quote) {
    if (kIsWeb || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      copyQuote(quote);
      Utils.graphic.showSnackbar(
        context,
        message: "quote.copy.success.name".tr(),
      );
      return;
    }

    String textToShare = "«${quote.name}»";

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
}
