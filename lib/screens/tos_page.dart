import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:unicons/unicons.dart";
import "package:url_launcher/url_launcher.dart";

/// Terms Of Service.
class TosPage extends StatefulWidget {
  const TosPage({super.key});

  @override
  State<StatefulWidget> createState() => _TosPageState();
}

class _TosPageState extends State<TosPage> {
  bool isFabVisible = false;

  final _pageScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton(),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: [
            body(),
          ],
        ),
      ),
    );
  }

  Widget advertisingBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock(text: "avertising".tr()),
        textSuperBlock(text: "avertising_content".tr()),
      ],
    );
  }

  Widget analyticsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock(text: "analytics".tr()),
        textSuperBlock(text: "analytics_content".tr()),
      ],
    );
  }

  Widget backButton() {
    return IconButton(
      tooltip: "back".tr(),
      onPressed: Beamer.of(context).beamBack,
      icon: const Icon(UniconsLine.arrow_left),
    );
  }

  Widget body() {
    final width = MediaQuery.of(context).size.width;

    double horPadding = 80.0;

    if (width < Utils.measurements.mobileWidthTreshold) {
      horPadding = 20.0;
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horPadding,
        vertical: 60.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              SizedBox(
                width: 600.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    backButton(),
                    pageTitle(),
                    termsBlock(),
                    cookiesBlock(),
                    analyticsBlock(),
                    advertisingBlock(),
                    inAppPurchasesBlock(),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget cookiesBlock() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      titleBlock(text: "cookies".tr()),
      textSuperBlock(text: "cookies_content".tr()),
    ]);
  }

  Widget floatingActionButton() {
    if (!isFabVisible) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: () {
        _pageScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Constants.colors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.arrow_upward),
    );
  }

  Widget inAppPurchasesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock(text: "iap".tr()),
        textSuperBlock(text: "iap_content".tr()),
      ],
    );
  }

  Widget pageTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Hero(
        tag: "tos_hero",
        child: Text(
          "tos".tr(),
          style: TextStyle(
            fontSize: 50.0,
            color: Constants.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget termsBlock() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSuperBlock(text: "tos_1".tr()),
          textSuperBlock(text: "tos_2".tr()),
          textSuperBlock(text: "tos_3".tr()),
          textSuperBlock(text: "tos_4".tr()),
          textSuperBlock(text: "tos_5".tr()),
          textSuperBlock(text: "tos_6".tr()),
          textSuperBlock(text: "tos_7".tr()),
          textSuperBlock(text: "tos_8".tr()),
          Text.rich(
            TextSpan(
              text: "tos_created_with".tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse("https://getterms.io/"));
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget titleBlock({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 16.0),
      child: Opacity(
        opacity: 1.0,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Constants.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget textSuperBlock({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && isFabVisible) {
      setState(() => isFabVisible = false);
    } else if (notification.metrics.pixels > 50 && !isFabVisible) {
      setState(() => isFabVisible = true);
    }

    return false;
  }
}
