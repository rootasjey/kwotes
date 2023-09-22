import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kwotes/globals/utils/snack.dart";
import "package:loggy/loggy.dart";
import "package:kwotes/actions/user_actions.dart";
import "package:kwotes/components/application_bar.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_body.dart";
import "package:kwotes/screens/forgot_password/forgot_password_page_completed.dart";
import "package:kwotes/types/intents/escape_intent.dart";

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with UiLoggy {
  /// If true, the operation is completed (e.g. email has been sent).
  bool isCompleted = false;

  /// True if the server is sending a new email to recover lost password.
  bool loading = false;

  /// Error message to display next to the email input.
  /// If this is empty, there's no error for this specific input.
  String _emailErrorMessage = "";

  /// Input controller to follow, validate & submit user email value.
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double windowWidth = MediaQuery.of(context).size.width;

    const shortcuts = <SingleActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
    };

    final actions = <Type, Action<Intent>>{
      EscapeIntent: CallbackAction(
        onInvoke: (Intent intent) => onCancel(),
      ),
    };

    if (isCompleted) {
      return Shortcuts(
        shortcuts: shortcuts,
        child: Actions(
          actions: actions,
          child: ForgotPasswordPageCompleted(
            windowWidth: windowWidth,
          ),
        ),
      );
    }

    if (loading) {
      return LoadingView.scaffold(
        message: "sending_password_recovery_email".tr(),
      );
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Scaffold(
          body: CustomScrollView(slivers: [
            const ApplicationBar(),
            ForgotPasswordPageBody(
              emailController: _emailController,
              emailErrorMessage: _emailErrorMessage,
              onCancel: onCancel,
              onEmailChanged: onEmailChanged,
              onSubmit: trySendResetLink,
            ),
          ]),
        ),
      ),
    );
  }

  /// Check for input validity: emptyness, format, availability.
  /// Poppulate email error message if there's an error in one of those steps.
  bool checkEmail(String email) {
    email = email.trim();

    if (email.isEmpty) {
      setState(() {
        _emailErrorMessage = "email_error.empty".tr();
      });

      Snack.error(
        context,
        message: "email.empty_no_valid".tr(),
      );

      return false;
    }

    final bool isWellFormatted = UserActions.checkEmailFormat(email);

    if (!isWellFormatted) {
      setState(() {
        _emailErrorMessage = "email_error.format".tr();
      });

      Snack.error(
        context,
        message: "email.not_valid".tr(),
      );

      return false;
    }

    return true;
  }

  /// Navigate back to previous or home page.
  void onCancel() {
    if (Beamer.of(context).beamingHistory.isNotEmpty) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }

  /// React to email changes and call `checkEmail(email)` method.
  void onEmailChanged(String email) async {
    checkEmail(email);
  }

  void trySendResetLink(String email) async {
    final bool isEmailOk = checkEmail(email);

    if (!isEmailOk) {
      return;
    }

    try {
      setState(() {
        loading = true;
        isCompleted = false;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        loading = false;
        isCompleted = true;
      });
    } catch (error) {
      loggy.error(error);

      setState(() {
        loading = false;
      });

      Snack.error(
        context,
        message: "email.doesnt_exist".tr(),
      );
    }
  }
}
