import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/globals/utils.dart";
import "package:text_wrap_auto_size/solution.dart";

class AddQuoteContent extends StatelessWidget {
  const AddQuoteContent({
    super.key,
    required this.solution,
    required this.contentController,
    this.isMobileSize = false,
    this.contentFocusNode,
    this.onContentChanged,
    this.onDeleteQuote,
    this.tooltipController,
    this.appBarRightChildren = const [],
  });

  /// Adapt user interface to moile size if true.
  final bool isMobileSize;

  /// Used to request focus on the content input.
  final FocusNode? contentFocusNode;

  /// Callback fired when the content input changes.
  final void Function(String newValue)? onContentChanged;

  /// Callback fired to delete the quote we're editing.
  final void Function()? onDeleteQuote;

  /// Tooltip controller.
  final JustTheController? tooltipController;

  /// Right children of the application bar.
  final List<Widget> appBarRightChildren;

  /// Text solution to apply a style that fits the screen size.
  final Solution solution;

  /// Content text controller.
  final TextEditingController contentController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        ApplicationBar(
          title: const SizedBox.shrink(),
          rightChildren: appBarRightChildren,
          isMobileSize: isMobileSize,
        ),
        SliverList.list(children: [
          Padding(
            padding: isMobileSize
                ? const EdgeInsets.only(
                    top: 24.0,
                    left: 12.0,
                    right: 12.0,
                    bottom: 190.0,
                  )
                : const EdgeInsets.only(
                    left: 36.0,
                    top: 36.0,
                    right: 36.0,
                    bottom: 240.0,
                  ),
            child: TextField(
              maxLines: null,
              autofocus: true,
              focusNode: contentFocusNode,
              controller: contentController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onChanged: onContentChanged,
              style: solution.style,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                hintMaxLines: null,
                hintText: "quote.start_typing".tr(),
                hintStyle: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 36.0 : 52.0,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
