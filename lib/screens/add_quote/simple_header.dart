import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class SimpleHeader extends StatelessWidget {
  /// Header for minimal add quote pages.
  const SimpleHeader({
    super.key,
    required this.languageSelector,
    this.isDark = false,
    this.margin = EdgeInsets.zero,
    this.onShowComplexBuilder,
    this.boxConstraints = const BoxConstraints(),
    this.show = false,
  });

  /// Constraints for this widget.
  final BoxConstraints boxConstraints;

  /// Adapt user interface to dark mode if true.
  final bool isDark;

  /// Wether to show this widget.
  final bool show;

  /// Margin around this widget.
  final EdgeInsets margin;

  /// Callback fired to show complex builder.
  final void Function()? onShowComplexBuilder;

  /// Language selector widget.
  final Widget languageSelector;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: margin,
      sliver: SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.end,
              children: [
                Utils.graphic.tooltip(
                  tooltipString: "quote.add.builder.complex".tr(),
                  child: ActionChip(
                    label: const Icon(TablerIcons.hammer, size: 20.0),
                    onPressed: onShowComplexBuilder,
                    elevation: 8.0,
                    side: BorderSide.none,
                    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: isDark ? Colors.black : Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
                languageSelector,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
