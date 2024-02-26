import "dart:ui";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_search_category.dart";

/// Search input for a search page.
class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    this.isMobileSize = false,
    this.searchCategory = EnumSearchCategory.quotes,
    this.padding = const EdgeInsets.only(left: 12.0),
    this.onChangedTextField,
    this.inputController,
    this.focusNode,
    this.bottom,
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

  /// Padding of this widget.
  final EdgeInsets padding;

  /// What type of category we are searching.
  final EnumSearchCategory searchCategory;

  /// Search focus node.
  final FocusNode? focusNode;

  /// Callback fired when typed text changes.
  final void Function(String)? onChangedTextField;

  /// Search input controller.
  final TextEditingController? inputController;

  /// Widget to display at the bottom.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final String hintText = "${"search.${searchCategory.name}".tr()}...";
    final Color backgroundColor =
        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7);

    int hintMaxLines = 1;
    if (inputController == null || inputController!.text.isEmpty) {
      hintMaxLines = 2;
    }

    const double toolbarHeight = 190.0;

    return SliverAppBar(
      primary: false,
      backgroundColor: backgroundColor,
      stretch: false,
      floating: true,
      pinned: false,
      snap: true,
      elevation: 0.0,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      collapsedHeight: toolbarHeight,
      expandedHeight: toolbarHeight,
      title: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Padding(
          padding: isMobileSize
              ? EdgeInsets.zero
              : padding.subtract(const EdgeInsets.only(left: 28.0)).add(
                    const EdgeInsets.only(top: 72.0),
                  ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: null,
                autofocus: true,
                cursorColor: Constants.colors.primary,
                focusNode: focusNode,
                controller: inputController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.search,
                onChanged: onChangedTextField,
                textAlign: TextAlign.center,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    fontSize: isMobileSize ? 32.0 : 54.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  hintMaxLines: hintMaxLines,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              bottom ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
