import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/globals/utils.dart";

class SimpleAppBar extends StatelessWidget {
  const SimpleAppBar({
    super.key,
    this.textTitle = "",
  });

  /// Text title of the app bar.
  final String textTitle;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverAppBar(
      snap: true,
      floating: true,
      centerTitle: false,
      title: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CircleButton(
            tooltip: "back".tr(),
            onTap: context.beamBack,
            backgroundColor: Colors.transparent,
            radius: 12.0,
            icon: Icon(
              TablerIcons.arrow_left,
              size: 18.0,
              color: foregroundColor?.withOpacity(0.6),
            ),
          ),
          Text(
            textTitle,
            style: Utils.calligraphy.body(
              textStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: foregroundColor?.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
    );
  }
}
