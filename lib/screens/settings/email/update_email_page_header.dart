import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class UpdateEmailPageHeader extends StatelessWidget {
  const UpdateEmailPageHeader({
    super.key,
    this.isMobileSize = false,
    this.accentColor,
    this.onTapLeftPartHeader,
  });

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Color of the right part header.
  final Color? accentColor;

  /// Callback fired when left part header is tapped.
  final void Function()? onTapLeftPartHeader;

  @override
  Widget build(BuildContext context) {
    const FontWeight fontWeight = FontWeight.w500;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        padding: isMobileSize
            ? const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0)
            : const EdgeInsets.only(top: 72.0),
        child: Column(
          crossAxisAlignment: isMobileSize
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            ActionChip(
              onPressed: context.beamBack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              label: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(TablerIcons.arrow_left),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("back".tr()),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onTapLeftPartHeader,
                  child: Text(
                    "settings.name".tr(),
                    textAlign: isMobileSize ? TextAlign.left : TextAlign.center,
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        fontSize: 24.0,
                        fontWeight: fontWeight,
                        height: 1.0,
                        color: foregroundColor?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              "email.name".tr(),
              textAlign: isMobileSize ? TextAlign.left : TextAlign.center,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  color: accentColor,
                  fontWeight: fontWeight,
                  fontSize: 54.0,
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: isMobileSize ? 0.9 : 0.4,
              child: Text(
                "email.update_tips".tr(),
                textAlign: isMobileSize ? TextAlign.start : TextAlign.center,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    color: foregroundColor?.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ]
              .animate(interval: 50.ms)
              .fadeIn(duration: 200.ms, curve: Curves.decelerate)
              .slideY(begin: 0.4, end: 0.0),
        ),
      ),
    );
  }
}
