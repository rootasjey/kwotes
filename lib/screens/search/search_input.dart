import "dart:ui";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/user_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/enums/enum_user_plan.dart";

/// Search input for a search page.
class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    this.isMobileSize = false,
    this.searchCategory = EnumSearchCategory.quotes,
    this.margin = EdgeInsets.zero,
    this.onChangedTextField,
    this.onConfirmSignOut,
    this.onTapClearIconButton,
    this.onTapCancelButton,
    this.onTapUserAvatar,
    this.userPlan = EnumUserPlan.free,
    this.inputController,
    this.focusNode,
    this.bottom,
  });

  /// True if this is a mobile size.
  /// Used to determine the size of the search input.
  final bool isMobileSize;

  /// Spacing aroung this widget.
  final EdgeInsets margin;

  /// What type of category we are searching.
  final EnumSearchCategory searchCategory;

  /// User plan.
  final EnumUserPlan userPlan;

  /// Search focus node.
  final FocusNode? focusNode;

  /// Callback fired when typed text changes.
  final void Function(String)? onChangedTextField;

  /// Callback fired on long press on user avatar to sign out the user.
  final void Function()? onConfirmSignOut;

  /// Callback fired when clear icon button is tapped.
  final void Function()? onTapClearIconButton;

  /// Callback fired when cancel button is tapped.
  final void Function()? onTapCancelButton;

  /// Callback fired when user avatar is tapped.
  final void Function()? onTapUserAvatar;

  /// Search input controller.
  final TextEditingController? inputController;

  /// Widget to display at the bottom.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final String hintText = "${"search.type_a_keyword".tr()}...";
    final BorderRadius borderRadius = BorderRadius.circular(24.0);

    int hintMaxLines = 1;
    if (inputController == null || inputController!.text.isEmpty) {
      hintMaxLines = 2;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isInputEmpty = inputController?.text.isEmpty ?? true;

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

    final bool isMobile = Utils.graphic.isMobile();
    final double toolbarHeight = isMobile ? 40.0 : 76.0;

    final searchInputWidthFactor = isMobileSize ? 1.0 : 0.75;

    return SliverAppBar(
      primary: false,
      stretch: false,
      floating: true,
      pinned: false,
      snap: true,
      elevation: 0.0,
      titleSpacing: 0.0,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      collapsedHeight: toolbarHeight,
      expandedHeight: toolbarHeight,
      backgroundColor: Colors.transparent,
      title: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: margin,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  UserAvatar(
                    showBadge: userPlan == EnumUserPlan.premium,
                    onTapUserAvatar: onTapUserAvatar,
                    onLongPressUserAvatar: onConfirmSignOut,
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: searchInputWidthFactor,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 125),
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
                              fontSize: isMobileSize ? 14.0 : 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: hintText,
                            isDense: true,
                            filled: true,
                            constraints: BoxConstraints(
                              minHeight: 0.0,
                              minWidth: 0.0,
                              maxHeight: isMobileSize ? 54.0 : 70.0,
                            ),
                            fillColor:
                                isDark ? Colors.grey.shade900 : Colors.white54,
                            suffixIcon: isInputEmpty ? null : clearIcon,
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: borderRadius,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.6,
                              ),
                              borderRadius: borderRadius,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: borderRadius,
                            ),
                            hintMaxLines: hintMaxLines,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 15),
                    curve: Curves.easeOutExpo,
                    opacity: focusNode?.hasFocus ?? false ? 1.0 : 0.0,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 125),
                      child: Container(
                        width: focusNode?.hasFocus ?? false ? null : 0.0,
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 100.0,
                          ),
                          child: TextButton(
                            onPressed: onTapCancelButton,
                            style: TextButton.styleFrom(
                              foregroundColor: Constants.colors.error,
                              backgroundColor: isDark
                                  ? Colors.grey.shade900
                                  : Colors.white60,
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            child: Text(
                              "cancel".tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Utils.calligraphy.body(
                                textStyle: TextStyle(
                                  fontSize: isMobileSize ? 15.0 : 18.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
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
