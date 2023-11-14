import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/dialogs/add_to_list/add_to_list_dialog.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_color_value_type.dart";
import "package:kwotes/types/enums/enum_main_genre.dart";
import "package:kwotes/types/enums/enum_snackbar_type.dart";
import "package:kwotes/types/enums/enum_topic.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/topic.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:unicons/unicons.dart";

/// Graphic utilities (everything associated with visual and UI).
class Graphic {
  const Graphic();

  /// Color filter to greyed out widget.
  final ColorFilter greyColorFilter = const ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  /// Starting delay for fade in y animmation.
  static int _delay = 0;

  /// Amount to add to delay for the next widget to animate.
  final int _step = 25;

  /// Where to start the fade in Y animation.
  double getBeginY() {
    return 60.0;
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

  int getNextAnimationDelay({String animationName = "", bool reset = false}) {
    if (reset) {
      _delay = 0;
    }

    final int prevDelay = _delay;
    _delay += _step;
    return prevDelay;
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
      return UniconsLine.brush_alt;
    }
    if (topic == EnumTopic.biology.name) {
      return UniconsLine.dna;
    }
    if (topic == EnumTopic.feelings.name) {
      return UniconsLine.heart;
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
      return TablerIcons.confetti;
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

    return UniconsLine.question;
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

  /// Show a dialog or a modal bottom sheet according to `isMobileSize` value.
  void showAdaptiveDialog(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isMobileSize = false,
    Color backgroundColor = Colors.white,
  }) {
    if (isMobileSize) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        backgroundColor: backgroundColor,
        builder: builder,
      );
      return;
    }

    showDialog(
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
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color defaultBackgroundColor =
        Theme.of(context).dialogBackgroundColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide(color: getSnackbarColorType(type), width: 4.0),
        ),
        backgroundColor: backgroundColor ?? defaultBackgroundColor,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  /// Show a snackbar with custom text.
  void showSnackbarWithCustomText(
    BuildContext context, {
    required Widget text,
  }) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color backgroundColor = Theme.of(context).dialogBackgroundColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: text,
        showCloseIcon: true,
        backgroundColor: backgroundColor,
        closeIconColor: foregroundColor?.withOpacity(0.6),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void showAddToListDialog(
    BuildContext context, {
    required Quote quote,
    required String userId,
    bool isMobileSize = false,
  }) {
    Utils.graphic.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) => AddToListDialog(
        asBottomSheet: isMobileSize,
        autoFocus: true,
        startInCreate: false,
        userId: userId,
        quotes: [quote],
      ),
    );
  }
}
