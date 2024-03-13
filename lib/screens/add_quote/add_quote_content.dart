import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/add_quote/step_chip.dart";
import "package:text_wrap_auto_size/solution.dart";

class AddQuoteContent extends StatelessWidget {
  const AddQuoteContent({
    super.key,
    required this.solution,
    required this.contentController,
    required this.languageSelector,
    required this.saveButton,
    this.isDark = false,
    this.isMobileSize = false,
    this.contentFocusNode,
    this.onContentChanged,
    this.onDeleteQuote,
    this.onTapCancelButton,
    this.tooltipController,
    this.onShowMinimalBuilder,
    this.appBarRightChildren = const [],
  });

  /// Use dark mode if true.
  final bool isDark;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Used to request focus on the content input.
  final FocusNode? contentFocusNode;

  /// Callback fired when the content input changes.
  final void Function(String newValue)? onContentChanged;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// Callback fired when cancel button is tapped.
  final void Function()? onTapCancelButton;

  /// Callback fired when minimal builder button is tapped.
  final void Function()? onShowMinimalBuilder;

  /// Tooltip controller.
  final JustTheController? tooltipController;

  /// Right children of the application bar.
  final List<Widget> appBarRightChildren;

  /// Text solution to apply a style that fits the screen size.
  final Solution solution;

  /// Content text controller.
  final TextEditingController contentController;

  /// Language selector.
  final Widget languageSelector;

  /// Save quote/draft button.
  final Widget saveButton;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).primaryColor;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    const double borderWidth = 1.0;
    const BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(4.0),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.end,
                children: [
                  Utils.graphic.tooltip(
                    tooltipString: "quote.add.builder.minimal".tr(),
                    child: ActionChip(
                      label: const Icon(TablerIcons.pencil, size: 20.0),
                      onPressed: onShowMinimalBuilder,
                      elevation: 8.0,
                      side: BorderSide.none,
                      surfaceTintColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      backgroundColor: isDark ? Colors.black : Colors.white,
                      shape: const StadiumBorder(),
                    ),
                  ),
                  languageSelector,
                  StepChip(
                    currentStep: 1,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: isMobileSize
                ? const EdgeInsets.only(
                    top: 6.0,
                    left: 24.0,
                    right: 24.0,
                    bottom: 190.0,
                  )
                : const EdgeInsets.only(
                    left: 36.0,
                    top: 36.0,
                    right: 36.0,
                    bottom: 240.0,
                  ),
            sliver: SliverList.list(
              children: [
                Card(
                  elevation: 6.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: borderRadius,
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        maxLines: null,
                        autofocus: true,
                        minLines: isMobileSize ? 4 : 2,
                        focusNode: contentFocusNode,
                        controller: contentController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: onContentChanged,
                        style: solution.style,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(24.0),
                          border: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: accentColor.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: accentColor.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              // color: foregroundColor,
                            ),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: Colors.pink,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              width: borderWidth,
                              color: accentColor,
                            ),
                          ),
                          hintMaxLines: 3,
                          hintText: "quote.content.hint_text".tr(),
                          hintStyle: solution.style,
                        ),
                      ),
                      if (contentFocusNode?.hasFocus ?? false)
                        Positioned(
                          top: 4.0,
                          right: 4.0,
                          child: CircleButton(
                            onTap: onTapCancelButton,
                            radius: 16.0,
                            tooltip: "cancel".tr(),
                            icon: Icon(
                              TablerIcons.fold_down,
                              size: 24.0,
                              color: foregroundColor?.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: saveButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
