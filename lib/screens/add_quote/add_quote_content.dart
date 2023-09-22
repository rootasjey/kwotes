import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/components/application_bar.dart";
import "package:text_wrap_auto_size/solution.dart";

class AddQuoteContent extends StatelessWidget {
  const AddQuoteContent({
    super.key,
    required this.solution,
    required this.contentController,
    this.contentFocusNode,
    this.onContentChanged,
    this.onDeleteQuote,
    this.tooltipController,
    this.appBarRightChildren = const [],
  });

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
          rightChildren: appBarRightChildren,
        ),
        SliverList.list(children: [
          Padding(
            padding: const EdgeInsets.only(
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
                hintText: "quote.start_typing".tr(),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
