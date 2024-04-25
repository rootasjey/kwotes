import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class AddToListHeader extends StatelessWidget {
  /// Header component for [AddToListDialog] parent component.
  const AddToListHeader({
    super.key,
    this.margin = EdgeInsets.zero,
    this.create = false,
    this.quoteLength = 0,
    this.onBack,
    this.onTapCreateList,
    this.showCreateListButton = true,
  });

  /// If true, the widget will show texts related to list creation.
  final bool create;

  /// If true, the widget will show create list button.
  final bool showCreateListButton;

  /// Margin of the header.
  final EdgeInsets margin;

  /// Trigger when the user tap on back button.
  final void Function()? onBack;

  /// Trigger when the user tap on create button.
  final void Function()? onTapCreateList;

  /// Number of quotes being added to the list.
  final int quoteLength;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: margin,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "lists.name".tr().toUpperCase(),
                textAlign: TextAlign.center,
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
              if (showCreateListButton)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: TextButton.icon(
                    onPressed: onTapCreateList,
                    icon: const Icon(TablerIcons.plus, size: 18.0),
                    label: Text(
                      "list.create.name".tr(),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Constants.colors.lists.withOpacity(0.1),
                      foregroundColor: Constants.colors.lists,
                      textStyle: Utils.calligraphy.body(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (onBack != null)
            Positioned(
              top: 0.0,
              right: 0.0,
              child: CircleButton(
                onTap: onBack,
                radius: 14,
                tooltip: "close".tr(),
                icon: const Icon(TablerIcons.x, size: 14.0),
                // backgroundColor: Constants.colors.delete,
              ),
            ),
        ],
      ),
    );
  }
}
