import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";

class DeleteAccountPageHeader extends StatelessWidget {
  const DeleteAccountPageHeader({
    super.key,
    this.isMobileSize = false,
    this.accentColor = Colors.amber,
    this.onTapLeftPartHeader,
    this.margin = EdgeInsets.zero,
  });

  /// Margin around this widget.
  final EdgeInsets margin;

  /// Adapt the user interface to narrow screen's size if true.
  final bool isMobileSize;

  /// Accent color.
  final Color accentColor;

  /// Callback fired when left part header is tapped.
  final void Function()? onTapLeftPartHeader;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: isMobileSize
              ? const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0)
              : const EdgeInsets.only(top: 72.0),
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: isMobileSize ? null : 700.0,
              child: Column(
                crossAxisAlignment: isMobileSize
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleButton(
                        onTap: context.beamBack,
                        radius: 16.0,
                        margin: const EdgeInsets.only(right: 8.0),
                        icon: Icon(
                          TablerIcons.arrow_left,
                          size: 18.0,
                          color: foregroundColor?.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        "account.delete.name".tr(),
                        textAlign:
                            isMobileSize ? TextAlign.left : TextAlign.center,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: accentColor.withOpacity(0.8),
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FractionallySizedBox(
                      alignment:
                          isMobileSize ? Alignment.topLeft : Alignment.center,
                      widthFactor: isMobileSize ? 1.0 : 0.6,
                      child: Text(
                        "account.delete.tips".tr(),
                        textAlign:
                            isMobileSize ? TextAlign.start : TextAlign.center,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: 14.0,
                            color: foregroundColor?.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
                    .animate(interval: 50.ms)
                    .fadeIn(duration: 200.ms, curve: Curves.decelerate)
                    .slideY(begin: 0.4, end: 0.0, duration: 250.ms),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
