import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/settings_location.dart";
import "package:kwotes/screens/settings/settings_item_data.dart";
import "package:kwotes/screens/settings/settings_page_header.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final bool isMobileSize = Utils.measurements.isMobileSize(context);

    final userFirestore = context.observe<UserFirestore>(
      EnumSignalId.userFirestore,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SettingsPageHeader(
            isMobileSize: isMobileSize,
            onTapBackButton: context.beamBack,
            title: "account.name".tr(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList.list(
              children: [
                SettingsItemData(
                  name: "username.edit.name".tr(),
                  description: userFirestore.name,
                  route: SettingsContentLocation.updateUsernameRoute,
                  iconData: TablerIcons.forms,
                ),
                SettingsItemData(
                  name: "email.edit.name".tr(),
                  description: userFirestore.email,
                  route: SettingsContentLocation.updateEmailRoute,
                  iconData: TablerIcons.mail,
                ),
                SettingsItemData(
                  name: "password.edit.name".tr(),
                  description: "password.update.description".tr(),
                  route: SettingsContentLocation.updatePasswordRoute,
                  iconData: TablerIcons.key,
                ),
                SettingsItemData(
                  name: "account.delete.name".tr(),
                  description: "account.delete.description".tr(),
                  route: SettingsContentLocation.deleteAccountRoute,
                  iconData: TablerIcons.trash,
                ),
              ].map((SettingsItemData settingsItemData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    onTap: () {
                      context.beamToNamed(settingsItemData.route);
                    },
                    // tileColor: Colors.white,
                    title: Text(settingsItemData.name),
                    dense: false,
                    leading: settingsItemData.iconData != null
                        ? Icon(
                            settingsItemData.iconData,
                            size: 18.0,
                            color: foregroundColor?.withOpacity(0.6),
                          )
                        : null,
                    trailing: Icon(
                      TablerIcons.chevron_right,
                      size: 18.0,
                      color: foregroundColor?.withOpacity(0.6),
                    ),
                    subtitle: Text(settingsItemData.description),
                    subtitleTextStyle: Utils.calligraphy.body(
                      textStyle: TextStyle(
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 200.0)),
        ],
      ),
    );
  }
}
