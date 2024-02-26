import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";

class ListsPageCreate extends StatelessWidget {
  /// Create list component.
  const ListsPageCreate({
    super.key,
    this.isMobileSize = false,
    this.show = false,
    this.accentColor = Colors.amber,
    this.onCancel,
    this.onCreate,
    this.onDescriptionChanged,
    this.onNameChanged,
    this.hintName = "",
    this.hintDescription = "",
  });

  /// Adapt UI for mobile size.
  final bool isMobileSize;

  /// Display this widget if true.
  final bool show;

  /// Accent color.
  final Color accentColor;

  /// Callback fired to hide this component.
  final void Function()? onCancel;

  /// Callback to create a new list.
  final void Function()? onCreate;

  /// Callback fired when name input has changed.
  final void Function(String name)? onNameChanged;

  /// Callback fired when description input has changed.
  final void Function(String description)? onDescriptionChanged;

  /// Hint list name.
  final String hintName;

  /// Hint list description.
  final String hintDescription;

  @override
  Widget build(BuildContext context) {
    final Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
        child: Container(
          height: show ? null : 0.0,
          padding: isMobileSize
              ? const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                )
              : const EdgeInsets.only(
                  left: 24.0,
                  right: 90.0,
                  bottom: 24.0,
                ),
          child: Material(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: accentColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            elevation: 0.0,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        autofocus: show ? true : false,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        onChanged: onNameChanged,
                        textInputAction: TextInputAction.next,
                        style: Utils.calligraphy.body(
                          textStyle: TextStyle(
                            fontSize: isMobileSize ? 24.0 : 42.0,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: hintName,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Divider(color: textColor?.withOpacity(0.4)),
                      TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: onDescriptionChanged,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => onCreate?.call(),
                        style: Utils.calligraphy.body(
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: hintDescription,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 8.0,
                          bottom: 6.0,
                        ),
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          alignment: WrapAlignment.start,
                          children: [
                            TextButton(
                              onPressed: onCancel,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0,
                                  vertical: 12.0,
                                ),
                                backgroundColor: Colors.black12,
                                foregroundColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                textStyle: Utils.calligraphy.body4(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                "cancel".tr(),
                              ),
                            ),
                            TextButton(
                              onPressed: onCreate,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0,
                                  vertical: 12.0,
                                ),
                                backgroundColor:
                                    onCreate != null ? accentColor : null,
                                foregroundColor:
                                    accentColor.computeLuminance() > 0.4
                                        ? Colors.black87
                                        : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                textStyle: Utils.calligraphy.body4(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                "list.create.name".tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 24.0,
                  right: 16.0,
                  child: CircleButton(
                    backgroundColor: Colors.black12,
                    icon: Icon(
                      TablerIcons.x,
                      color: textColor,
                    ),
                    onTap: onCancel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
