import "package:flutter/material.dart";
import "package:kwotes/components/fade_in_y.dart";
import "package:kwotes/components/popup_menu/popup_menu_icon.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";

/// A PopupMenuItem which display a checkmark if active.
class PopupMenuToggleItem<T> extends PopupMenuItem<T> {
  PopupMenuToggleItem({
    Key? key,
    required this.textLabel,
    this.newEnabled = true,
    this.selected = false,
    this.foregroundColor,
    this.newHeight = kMinInteractiveDimension,
    this.delay = const Duration(seconds: 0),
    this.newPadding,
    this.newMouseCursor,
    this.newValue,
    this.icon,
  }) : super(
          key: key,
          value: newValue,
          enabled: newEnabled,
          height: newHeight,
          padding: newPadding,
          mouseCursor: newMouseCursor,
          child: FadeInY(
            beginY: 12.0,
            delay: delay,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Opacity(
                opacity: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: icon.runtimeType == PopupMenuIcon
                            ? PopupMenuIcon(
                                (icon as PopupMenuIcon).iconData,
                                color: foregroundColor ?? icon.color,
                              )
                            : icon,
                      ),
                    Expanded(
                      child: Text(
                        textLabel,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            color: foregroundColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: foregroundColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

  final Widget? icon;
  final String textLabel;
  final T? newValue;
  final bool newEnabled;
  final Color? foregroundColor;
  final double newHeight;
  final EdgeInsets? newPadding;
  final MouseCursor? newMouseCursor;
  final bool selected;
  final Duration delay;

  PopupMenuToggleItem<T> copyWith({
    bool? enabled,
    bool? selected,
    Color? selectedColor,
    double? height,
    Duration? delay,
    EdgeInsets? padding,
    MouseCursor? mouseCursor,
    String? textLabel,
    T? value,
    Widget? icon,
  }) {
    return PopupMenuToggleItem(
      newEnabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      foregroundColor: selectedColor ?? foregroundColor,
      newHeight: height ?? this.height,
      delay: delay ?? this.delay,
      newPadding: padding ?? this.padding,
      newMouseCursor: mouseCursor ?? this.mouseCursor,
      textLabel: textLabel ?? this.textLabel,
      newValue: value ?? this.value,
      icon: icon ?? this.icon,
    );
  }
}
