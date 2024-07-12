import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

class EmptyAccountSettingsView extends StatelessWidget {
  const EmptyAccountSettingsView({
    super.key,
    this.onTapGetAnAccount,
  });

  /// Callback fired when "Get an account" button is tapped.
  final void Function()? onTapGetAnAccount;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Card(
          elevation: 2.0,
          surfaceTintColor: Constants.colors.secondary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: Constants.colors.secondary.withOpacity(1.0),
              width: 1.0,
            ),
          ),
          child: InkWell(
            onTap: onTapGetAnAccount,
            splashColor: Constants.colors.secondary.withOpacity(0.2),
            highlightColor: Constants.colors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    TablerIcons.seeding,
                    size: 18.0,
                    color: Constants.colors.secondary,
                  ),
                  const Spacer(),
                  Text(
                    "account.get".tr(),
                    style: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        color: foregroundColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    TablerIcons.seeding,
                    size: 18.0,
                    color: Constants.colors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
