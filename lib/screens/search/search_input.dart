import "dart:ui";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
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
    this.onTapClearIconButton,
    this.onTapCancelButton,
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

  /// Callback fired when clear icon button is tapped.
  final void Function()? onTapClearIconButton;

  /// Callback fired when cancel button is tapped.
  final void Function()? onTapCancelButton;

  /// Search input controller.
  final TextEditingController? inputController;

  /// Widget to display at the bottom.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final String hintText = "${"search.${searchCategory.name}".tr()}...";

    int hintMaxLines = 1;
    if (inputController == null || inputController!.text.isEmpty) {
      hintMaxLines = 2;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isInputEmpty = inputController?.text.isEmpty ?? true;
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    final Color backgroundColor = isDark ? Colors.black : Colors.white;

    final Widget clearIcon = Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleButton(
        tooltip: "search.clear".tr(),
        icon: const Icon(TablerIcons.x, size: 16.0),
        radius: 12.0,
        shape: const CircleBorder(),
        onTap: onTapClearIconButton,
        backgroundColor: isDark ? Colors.white12 : Colors.black12,
      ),
    );

    final double toolbarHeight = isMobileSize ? 120.0 : 190.0;

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      autofocus: false,
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
                          fontSize: isMobileSize ? 14.0 : 24.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        isDense: true,
                        suffixIcon: isInputEmpty ? null : clearIcon,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: foregroundColor,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple.shade400,
                            width: 1.6,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: foregroundColor,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintMaxLines: hintMaxLines,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                      ),
                    ),
                  ),
                  if (focusNode?.hasFocus ?? false)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextButton(
                        onPressed: onTapCancelButton,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: Text(
                          "cancel".tr(),
                          style: Utils.calligraphy.body(
                            textStyle: TextStyle(
                              fontSize: isMobileSize ? 14.0 : 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              bottom ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
