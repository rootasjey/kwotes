import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class AddToListHeader extends StatelessWidget {
  /// Header component for [AddToListDialog] parent component.
  const AddToListHeader({
    super.key,
    this.margin = EdgeInsets.zero,
    this.create = false,
    this.quoteLength = 0,
    this.onBack,
  });

  /// If true, the widget will show texts related to list creation.
  final bool create;

  /// Margin of the header.
  final EdgeInsets margin;

  /// Trigger when the user tap on back button.
  final void Function()? onBack;

  /// Number of quotes being added to the list.
  final int quoteLength;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: margin,
      child: Column(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(TablerIcons.arrow_back),
            ),
          Text(
            "lists.name".tr().toUpperCase(),
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 18.0,
                color: foregroundColor?.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              create
                  ? "list.create.name".tr()
                  : "list.add.quote"
                      .plural(quoteLength, args: [quoteLength.toString()]),
              textAlign: TextAlign.center,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: 14.0,
                  color: foregroundColor?.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
