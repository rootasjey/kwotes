import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:jiffy/jiffy.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/screens/home/home_text_button.dart";
import "package:kwotes/types/reference.dart";

class ReferenceMetadaColumn extends StatelessWidget {
  /// Show reference's metadata.
  /// Better suited for mobile size.
  const ReferenceMetadaColumn({
    super.key,
    required this.reference,
    required this.foregroundColor,
    this.show = true,
    this.margin = EdgeInsets.zero,
    this.onToggleOpen,
    this.isOpen = true,
  });

  /// Expand this widget if true.
  final bool isOpen;

  /// Hide this widget if true.
  /// Default to true.
  final bool show;

  /// Text foreground color.
  final Color foregroundColor;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Callback fired to toggle this widget size.
  final void Function()? onToggleOpen;

  /// Reference data for this component.
  final Reference reference;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    const EdgeInsets padding = EdgeInsets.all(6.0);
    final List<Widget> children = [];

    if (reference.type.primary.isNotEmpty) {
      children.add(
        Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  TablerIcons.triangle,
                  color: foregroundColor.withOpacity(0.6),
                ),
              ),
              Expanded(
                child: Text(
                  "genre.primary.${reference.type.primary}".tr(),
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      color: foregroundColor.withOpacity(0.6),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (reference.type.secondary.isNotEmpty) {
      children.add(
        Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  TablerIcons.hexagon,
                  color: foregroundColor.withOpacity(0.6),
                ),
              ),
              Expanded(
                  child: Text(
                "genre.secondary.${reference.type.secondary.toLowerCase()}"
                    .tr(),
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: foregroundColor.withOpacity(0.6),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
            ],
          ),
        ),
      );
    }

    if (!reference.release.dateEmpty) {
      children.add(
        Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  TablerIcons.jetpack,
                  color: foregroundColor.withOpacity(0.6),
                ),
              ),
              Text(
                Jiffy.parseFromDateTime(reference.release.original).yMMMMd,
                style: Utils.calligraphy.body(
                  textStyle: TextStyle(
                    color: foregroundColor.withOpacity(0.6),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOpen)
            HomeTextButton(
              icon: const Icon(TablerIcons.eye, size: 16.0),
              onPressed: onToggleOpen,
              textValue: "see_metadata".tr(),
              textStyle: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          if (isOpen)
            HomeTextButton(
              icon: const Icon(TablerIcons.x, size: 16.0),
              onPressed: onToggleOpen,
              textValue: "close".tr(),
              textStyle: Utils.calligraphy.body(
                textStyle: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          AnimatedSize(
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              height: isOpen ? null : 0.0,
              child: Card(
                elevation: 8.0,
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: onToggleOpen,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        return children[index];
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider();
                      },
                      itemCount: children.length,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
