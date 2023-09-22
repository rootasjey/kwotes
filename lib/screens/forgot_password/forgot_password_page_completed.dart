import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/router/locations/home_location.dart";

/// A Scaffold widget showing a success result after a
/// password recovery email has been sent.
class ForgotPasswordPageCompleted extends StatelessWidget {
  const ForgotPasswordPageCompleted({
    super.key,
    required this.windowWidth,
  });

  /// Value used to adapt the layout to the window's width.
  final double windowWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const ApplicationBar(),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Icon(
                    Icons.check_circle,
                    size: 80.0,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: windowWidth > 400.0 ? 320.0 : 280.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                        child: Text(
                          "email.password_reset_link".tr(),
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: .6,
                        child: Text("email.check_spam".tr()),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 55.0,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Beamer.of(context).beamToNamed(HomeLocation.route);
                    },
                    child: const Opacity(
                      opacity: .6,
                      child: Text(
                        "Return to home",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
