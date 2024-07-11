import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;
    final Color primaryColor = Constants.colors.primary;
    final Color secondaryColor = Constants.colors.secondary;

    final Size windowSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: windowSize.height - 140.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppIcon(size: 54.0),
                      Text(
                        "Hi, it's Carrot again!",
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
                          left: 24.0,
                          right: 24.0,
                          bottom: 42.0,
                        ),
                        child: Text(
                          "If you want to use the full app, you can create an account. The choice is yours!",
                          textAlign: TextAlign.center,
                          style: Utils.calligraphy.body(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Beamer.of(context).beamToNamed(
                          DashboardContentLocation.signupRoute,
                        ),
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
                          onPressed: () => Beamer.of(context).beamToNamed(
                            DashboardContentLocation.signinRoute,
                          ),
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
                          onPressed: () {
                            context
                                .get<Signal<String>>(
                                    EnumSignalId.navigationBarPath)
                                .updateValue((prevValue) =>
                                    "${HomeContentLocation.route}-${DateTime.now()}");
                          },
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
            ),
          ],
        ),
      ),
    );
  }
}
