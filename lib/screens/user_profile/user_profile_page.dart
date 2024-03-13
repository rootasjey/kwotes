import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/better_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/add_quote/simple_app_bar.dart";
import "package:kwotes/screens/user_profile/section_button.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_firestore.dart";

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    final UserFirestore userFirestore =
        context.observe<UserFirestore>(EnumSignalId.userFirestore);

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SimpleAppBar(
              textTitle: "account.name".tr(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  children: [
                    BetterAvatar(
                      heroTag: "user-avatar",
                      onTap: onTapUserAvatar,
                      radius: 24.0,
                      imageProvider: const AssetImage(
                        "assets/images/profile-picture-avocado.png",
                      ),
                    ),
                    Text(
                      userFirestore.name,
                      style: Utils.calligraphy.body(
                        textStyle: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: foregroundColor?.withOpacity(0.8),
                          backgroundColor: Constants.colors.getRandomPastel(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionButton(
                            onTap: onTapUpdateEmail,
                            textTitle: "email.update".tr(),
                            textSubtitle: userFirestore.email,
                            iconData: TablerIcons.mail,
                            foregroundColor: foregroundColor,
                          ),
                          SectionButton(
                            onTap: onTapUpdateUsername,
                            textTitle: "username.update.name".tr(),
                            textSubtitle: userFirestore.name,
                            iconData: TablerIcons.user,
                            foregroundColor: foregroundColor,
                          ),
                          SectionButton(
                            onTap: onTapUpdatePassword,
                            textTitle: "password.update.name".tr(),
                            textSubtitle: "password.update.description".tr(),
                            iconData: TablerIcons.lock,
                            foregroundColor: foregroundColor,
                          ),
                          SectionButton(
                            onTap: onTapDeleteAccount,
                            textTitle: "account.delete.name".tr(),
                            textSubtitle: "This action is irreversible",
                            iconData: TablerIcons.trash,
                            foregroundColor: foregroundColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ActionChip(
                              onPressed: onTapSignout,
                              backgroundColor: Colors.white,
                              shape: const StadiumBorder(
                                side: BorderSide(
                                  width: 0.0,
                                  color: Colors.transparent,
                                ),
                              ),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    TablerIcons.logout,
                                    color: foregroundColor?.withOpacity(0.6),
                                    size: 18.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("signout".tr()),
                                  ),
                                ],
                              ),
                              labelStyle: Utils.calligraphy.body(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: foregroundColor?.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ]
                            .animate(
                              interval: const Duration(milliseconds: 25),
                            )
                            .slideY(
                              begin: 2.0,
                              end: 0.0,
                              curve: Curves.decelerate,
                              duration: const Duration(milliseconds: 250),
                            )
                            .fadeIn(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapSignout() async {
    Navigator.of(context).pop();
    final bool success = await Utils.state.signOut();
    if (!success) return;
    if (!context.mounted) return;
    Beamer.of(context, root: true).beamToReplacementNamed(HomeLocation.route);
  }

  void onTapUserAvatar() {}

  /// Navigate to the delete account page.
  void onTapDeleteAccount() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.deleteAccountRoute,
    );
  }

  /// Navigate to the update email page.
  void onTapUpdateEmail() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updateEmailRoute,
    );
  }

  /// Navigate to the update password page.
  void onTapUpdatePassword() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updatePasswordRoute,
    );
  }

  /// Navigate to the update username page.
  void onTapUpdateUsername() {
    Beamer.of(context).beamToNamed(
      DashboardContentLocation.updateUsernameRoute,
    );
  }
}
