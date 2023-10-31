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
    this.searchCategory = EnumSearchCategory.quote,
    this.inputController,
    this.onChangedTextField,
    this.focusNode,
    this.padding = const EdgeInsets.only(left: 12.0),
    this.isMobileSize = false,
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

  @override
  Widget build(BuildContext context) {
    final String hintText = "${"search.${searchCategory.name}s".tr()}...";
    final Color backgroundColor =
        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7);

    return SliverAppBar(
      primary: false,
      backgroundColor: backgroundColor,
      stretch: false,
      pinned: true,
      toolbarHeight: 66.0,
      automaticallyImplyLeading: false,
      collapsedHeight: 66.0,
      expandedHeight: 100.0,
      title: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Padding(
          padding: isMobileSize
              ? EdgeInsets.zero
              : padding.subtract(const EdgeInsets.only(left: 28.0)),
          child: TextField(
            maxLines: null,
            autofocus: true,
            cursorColor: Constants.colors.primary,
            focusNode: focusNode,
            controller: inputController,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: onChangedTextField,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: isMobileSize ? 24.0 : 54.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ),
      ),
    );
  }
}
