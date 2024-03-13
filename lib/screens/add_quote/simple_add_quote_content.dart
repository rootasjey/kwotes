import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class SimpleAddQuoteContent extends StatelessWidget {
  const SimpleAddQuoteContent({
    super.key,
    required this.languageSelector,
    required this.contentController,
    this.isDark = false,
    this.isMobileSize = false,
    this.boxConstraints = const BoxConstraints(),
    this.margin = EdgeInsets.zero,
    this.contentFocusNode,
    this.onContentChanged,
    this.onTapCancelButton,
  });

  /// Use dark mode if true.
  final bool isDark;

  /// Adapt user interface to mobile size if true.
  final bool isMobileSize;

  /// Constraints for this widget.
  final BoxConstraints boxConstraints;

  /// Margin around this widget.
  final EdgeInsets margin;

  /// Used to request focus on the content input.
  final FocusNode? contentFocusNode;

  /// Callback fired when the content input changes.
  final void Function(String newValue)? onContentChanged;

  /// Callback fired when cancel button is tapped.
  final void Function()? onTapCancelButton;

  /// Content text controller.
  final TextEditingController contentController;

  /// Language selector.
  final Widget languageSelector;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).primaryColor;
    const double borderWidth = 1.0;
    const BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(4.0),
    );

    return SliverPadding(
      padding: margin,
      sliver: SliverList.list(
        children: [
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: boxConstraints,
              child: Card(
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
                        // hintStyle: solution.style,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
