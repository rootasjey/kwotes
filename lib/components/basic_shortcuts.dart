import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/types/intents/add_quote_intent.dart";
import "package:kwotes/types/intents/dashboard_intent.dart";
import "package:kwotes/types/intents/escape_intent.dart";
import "package:kwotes/types/intents/home_intent.dart";
import "package:kwotes/types/intents/search_intent.dart";

/// Add keyboard shortcuts events on top of a [Widget].
/// Events triggered: [escape], [ctrl+d], [crtl+s].
/// Supply a [focusNode] parameter to force focus request
/// if it doesn't automatically works.
class BasicShortcuts extends StatelessWidget {
  const BasicShortcuts({
    Key? key,
    required this.child,
    this.onCancel,
    this.focusNode,
    this.autofocus = true,
    this.additionalActions = const {},
    this.additionalShortcuts = const {},
  }) : super(key: key);

  /// If true, this component will try to request focus on load.
  final bool autofocus;

  /// Callback fired when escape button is pressed.
  final Function()? onCancel;

  /// Can be necessary to force focus request and receive events.
  final FocusNode? focusNode;

  /// Additional shortcuts.
  final Map<LogicalKeySet, Intent> additionalShortcuts;

  /// Additional actions.
  final Map<Type, Action<Intent>> additionalActions;

  /// Child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode?.requestFocus();
    });

    final Map<LogicalKeySet, Intent> shortcuts = {
      LogicalKeySet(
        LogicalKeyboardKey.escape,
      ): const EscapeIntent(),
    };

    shortcuts.addAll(additionalShortcuts);

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (EscapeIntent escapeIntent) {
              return onCancel?.call();
            },
          ),
          AddQuoteIntent: CallbackAction<AddQuoteIntent>(
            onInvoke: (AddQuoteIntent addQuoteIntent) {
              return context
                  .beamToNamed(DashboardContentLocation.addQuoteRoute);
            },
          ),
          DashboardIntent: CallbackAction<DashboardIntent>(
            onInvoke: (DashboardIntent dashboardIntent) {
              return context.beamToNamed(DashboardLocation.route);
            },
          ),
          HomeIntent: CallbackAction<HomeIntent>(
            onInvoke: (HomeIntent homeIntent) {
              return context.beamToNamed(HomeLocation.route);
            },
          ),
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (SearchIntent searchIntent) {
              return context.beamToNamed(SearchLocation.route);
            },
          ),
        }..addAll(additionalActions),
        child: Focus(
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }
}
