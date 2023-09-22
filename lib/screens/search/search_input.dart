import "dart:ui";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_search_entity.dart";

/// Search input for a search page.
class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    this.searchEntity = EnumSearchEntity.quote,
    this.inputController,
    this.onChangedTextField,
    this.focusNode,
    this.padding = const EdgeInsets.only(left: 12.0),
  });

  /// Padding of this widget.
  final EdgeInsets padding;

  /// What type of entity we are searching.
  final EnumSearchEntity searchEntity;

  /// Search focus node.
  final FocusNode? focusNode;

  /// Callback fired when typed text changes.
  final void Function(String)? onChangedTextField;

  /// Search input controller.
  final TextEditingController? inputController;

  @override
  Widget build(BuildContext context) {
    final String hintText = "${"search.${searchEntity.name}s".tr()}...";

    return SliverAppBar(
      primary: false,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
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
          padding: padding.subtract(const EdgeInsets.only(left: 28.0)),
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
              textStyle: const TextStyle(
                fontSize: 54.0,
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
