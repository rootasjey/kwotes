import "dart:ui";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:bottom_sheet/bottom_sheet.dart";
import "package:flutter/material.dart";
import "package:kwotes/components/basic_shortcuts.dart";
import "package:kwotes/router/navigation_state_helper.dart";

class SettingsDialogPage extends StatefulWidget {
  const SettingsDialogPage({super.key});

  @override
  State<SettingsDialogPage> createState() => _SettingsDialogPageState();
}

class _SettingsDialogPageState extends State<SettingsDialogPage> {
  @override
  void initState() {
    super.initState();
    openDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: const SizedBox.shrink(),
      ),
    );
  }

  void openDialog() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      NavigationStateHelper.rootContext = context;
      showFlexibleBottomSheet(
        context: context,
        minHeight: 0.0,
        initHeight: 0.8,
        maxHeight: 0.9,
        anchors: [0.0, 0.9],
        bottomSheetBorderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        builder: (
          BuildContext context,
          scrollController,
          bottomSheetOffset,
        ) {
          NavigationStateHelper.bottomSheetScrollController = scrollController;
          return PopScope(
            onPopInvoked: (bool didPop) async {
              NavigationStateHelper.navigateBackToLastRoot(context);
            },
            child: Theme(
              data: AdaptiveTheme.of(context).theme,
              child: BasicShortcuts(
                onCancel: context.beamBack,
                child: Scaffold(
                  body: Beamer(
                    key: NavigationStateHelper.settingsBeamerKey,
                    routerDelegate:
                        NavigationStateHelper.settingsRouterDelegate,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
