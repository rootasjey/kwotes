import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/types/intents/enter_intent.dart";
import "package:kwotes/types/intents/escape_intent.dart";

/// Add keyboard shortcuts events to a [Widget].
/// Events triggered: [escape], [space], [enter].
/// Supply a [focusNode] parameter to force focus request
/// if it doesn't automatically works.
class ValidationShortcuts extends StatelessWidget {
  const ValidationShortcuts({
    Key? key,
    required this.child,
    this.onValidate,
    this.onCancel,
    this.focusNode,
    this.spaceActive = true,
    this.autofocus = true,
  }) : super(key: key);

  final Widget child;
  final Function()? onValidate;
  final Function()? onCancel;
  final FocusNode? focusNode;

  /// If true, space bar will submit this dialog (as well as 'enter').
  final bool spaceActive;

  /// If true, this component will try to request focus on load.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode?.requestFocus();
    });

    Map<LogicalKeySet, Intent> shortcuts = {
      LogicalKeySet(LogicalKeyboardKey.enter): const EnterIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
    };

    if (spaceActive) {
      shortcuts.putIfAbsent(
        LogicalKeySet(LogicalKeyboardKey.space),
        () => const EnterIntent(),
      );
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          EnterIntent: CallbackAction<EnterIntent>(
            onInvoke: (EnterIntent enterIntent) {
              return onValidate?.call();
            },
          ),
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (EscapeIntent escapeIntent) {
              return onCancel?.call();
            },
          ),
        },
        child: Focus(
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }
}
