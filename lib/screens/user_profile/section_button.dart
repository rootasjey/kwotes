import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";

class SectionButton extends StatelessWidget {
  const SectionButton({
    super.key,
    required this.iconData,
    required this.textTitle,
    required this.textSubtitle,
    this.foregroundColor,
    this.onTap,
  });

  /// Foreground color.
  final Color? foregroundColor;

  final IconData iconData;
  final String textTitle;
  final String textSubtitle;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        iconColor: foregroundColor?.withOpacity(0.6),
        textColor: foregroundColor?.withOpacity(0.6),
        leading: Icon(iconData, size: 18.0),
        titleTextStyle: Utils.calligraphy.body(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        ),
        // subtitleTextStyle: TextStyle(
        //   color: Colors.amber,
        // ),
        title: Text(textTitle.toUpperCase()),
        subtitle: Text(
          textSubtitle,
          style: TextStyle(
            color: foregroundColor?.withOpacity(0.4),
          ),
        ),
        trailing: const Icon(TablerIcons.chevron_right),
        onTap: onTap,
      ),
    );
    // return const SizedBox.shrink();
    // return ListTile(
    //   leading: const Icon(TablerIcons.user),
    //   title: Text("account.name".tr()),
    //   trailing: const Icon(TablerIcons.chevron_right),
    //   onTap: () => Navigator.of(context).pushNamed(HomeLocation.routeName),
    // );
  }
}
