import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/onboarding_feature_item.dart";

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color primaryColor = Constants.colors.primary;
    final Color secondaryColor = Constants.colors.secondary;

    final Size windowSize = MediaQuery.of(context).size;

    final List<OnboardingFeatureItem> features = [
      OnboardingFeatureItem(
        title: "Create custom quotes",
        description: "Create your first quote and share it with the world!",
        icon: TablerIcons.plus,
      ),
      OnboardingFeatureItem(
        title: "Discover a full quote database",
        description: "",
        icon: TablerIcons.quote,
      ),
      OnboardingFeatureItem(
        title: "Build personal collection",
        description: "",
        icon: TablerIcons.list,
      ),
      OnboardingFeatureItem(
        title: "Share inspiration easily",
        description: "",
        icon: TablerIcons.speakerphone,
      ),
    ];

    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: windowSize.height - 280.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppIcon(size: 54.0),
                          Text(
                            "Hi, it's Carrot!",
                            style: Utils.calligraphy.body(
                              textStyle: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 6.0,
                              left: 12.0,
                              right: 12.0,
                              bottom: 42.0,
                            ),
                            child: Text(
                              "Welcome to Kwotes. A place where you can create, customize and share inspiration",
                              textAlign: TextAlign.center,
                              style: Utils.calligraphy.body(
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Column(
                              children:
                                  features.map((OnboardingFeatureItem feature) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: Container(
                                            foregroundDecoration: BoxDecoration(
                                              border: Border.all(
                                                color: foregroundColor ??
                                                    Colors.black,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                              // color: secondaryColor,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Icon(
                                                feature.icon,
                                                size: 18.0,
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        child: Text(
                                          feature.title,
                                          style: Utils.calligraphy.body(
                                            textStyle: const TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 24.0,
              left: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => onPressedCreateAccount(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? primaryColor.withOpacity(0.1) : null,
                        elevation: 1.0,
                        enableFeedback: true,
                        foregroundColor: foregroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: BorderSide(
                            color: primaryColor.withOpacity(0.4),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "account.create".tr(),
                            style: Utils.calligraphy.body(
                              textStyle: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextButton(
                        onPressed: () => onPressedSignIn(context),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? secondaryColor.withOpacity(0.1)
                              : secondaryColor.withOpacity(0.1),
                          elevation: 0.0,
                          enableFeedback: true,
                          foregroundColor: foregroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: BorderSide(
                              color: primaryColor.withOpacity(0.4),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "signin.name".tr(),
                              style: Utils.calligraphy.body(
                                textStyle: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () =>
                            onPressedContinueWithoutAccount(context),
                        style: TextButton.styleFrom(
                          foregroundColor: foregroundColor?.withOpacity(0.6),
                        ),
                        child: const Text(
                          "Continue without an account",
                          textAlign: TextAlign.center,
                        ),
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

  void initProps(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final Brightness? currentBrightness =
          AdaptiveTheme.maybeOf(context)?.brightness;

      final SystemUiOverlayStyle overlayStyle =
          currentBrightness == Brightness.dark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.yellow, // optional
                  systemNavigationBarColor: Colors.red,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.blue, // optional
                  systemNavigationBarColor: Colors.amber,
                  // systemNavigationBarColor: Colors.white,
                  systemNavigationBarDividerColor: Colors.red,
                );

      SystemChrome.setSystemUIOverlayStyle(overlayStyle);
    });
  }

  void onPressedCreateAccount(BuildContext context) {
    int milliseconds = 0;

    if (NavigationStateHelper.homePageTabIndex != 2) {
      milliseconds = 150;
      context.get<Signal<String>>(EnumSignalId.navigationBarPath).updateValue(
          (String _) =>
              "${DashboardLocation.route}-${DashboardContentLocation.signupRoute}");
    }

    Future.delayed(Duration(milliseconds: milliseconds), () {
      Beamer.of(context).beamToNamed(
        DashboardContentLocation.signupRoute,
      );
    });
  }

  void onPressedSignIn(BuildContext context) {
    int milliseconds = 0;

    if (NavigationStateHelper.homePageTabIndex != 2) {
      milliseconds = 150;
      context.get<Signal<String>>(EnumSignalId.navigationBarPath).updateValue(
          (String _) =>
              "${DashboardLocation.route}-${DashboardContentLocation.signinRoute}");
    }

    Future.delayed(Duration(milliseconds: milliseconds), () {
      Beamer.of(context).beamToNamed(
        DashboardContentLocation.signinRoute,
      );
    });
  }

  void onPressedContinueWithoutAccount(BuildContext context) {
    context.get<Signal<String>>(EnumSignalId.navigationBarPath).updateValue(
        (prevValue) => "${HomeContentLocation.route}-${DateTime.now()}");

    Beamer.of(context).beamToNamed(
      HomeContentLocation.route,
    );
  }
}
