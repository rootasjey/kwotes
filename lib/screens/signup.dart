import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = '';
  String password = '';
  String confirmPassword = '';
  String username = '';

  bool isEmailAvailable = true;
  bool isNameAvailable = true;

  String emailErrorMessage = '';
  String nameErrorMessage = '';

  bool isCheckingEmail = false;
  bool isCheckingName = false;

  Timer emailTimer;
  Timer nameTimer;

  bool isCheckingAuth = false;
  bool isCompleted = false;
  bool isSigningUp = false;

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();
  final confirmPasswordNode = FocusNode();

  @override
  initState() {
    super.initState();
    ensureNotConnected();
  }

  @override
  void dispose() {
    super.dispose();
    usernameNode.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: <Widget>[
              AppIcon(
                padding: const EdgeInsets.only(top: 30.0, bottom: 60.0),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 300.0,
                ),
                child: SizedBox(
                  width: 300.0,
                  child: body(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isSigningUp) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          textTitle: 'Signing up...',
        ),
      );
    }

    return idleContainer();
  }

  Widget emailInput() {
    return FadeInY(
      delay: 0.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 60.0),
        child: TextFormField(
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            icon: Icon(Icons.email),
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) async {
            email = value;

            setState(() {
              isCheckingEmail = true;
            });

            final isWellFormatted = checkEmailFormat(email);

            if (!isWellFormatted) {
              setState(() {
                isCheckingEmail = false;
                emailErrorMessage = 'The value is not a valid email address';
              });

              return;
            }

            if (emailTimer != null) {
              emailTimer.cancel();
              emailTimer = null;
            }

            emailTimer = Timer(1.seconds, () async {
              final isAvailable = await checkEmailAvailability(email);
              if (!isAvailable) {
                setState(() {
                  isCheckingEmail = false;
                  emailErrorMessage = 'This email address is not available';
                });

                return;
              }

              setState(() {
                isCheckingEmail = false;
                emailErrorMessage = '';
              });
            });
          },
          onFieldSubmitted: (_) => usernameNode.requestFocus(),
          validator: (value) {
            if (value.isEmpty) {
              return 'Email cannot be empty';
            }

            return null;
          },
        ),
      ),
    );
  }

  Widget emailInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(emailErrorMessage,
          style: TextStyle(
            color: Colors.red.shade300,
          )),
    );
  }

  Widget header() {
    return Row(
      children: <Widget>[
        FadeInX(
          beginX: 10.0,
          delay: 100.milliseconds,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: IconButton(
              onPressed: () => context.router.pop(),
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            FadeInY(
              beginY: 50.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 200.milliseconds,
              beginY: 50.0,
              child: Opacity(
                opacity: .6,
                child: Text('Create a new account'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        header(),
        emailInput(),
        if (isCheckingEmail) emailProgress(),
        if (emailErrorMessage.isNotEmpty) emailInputError(),
        nameInput(),
        if (isCheckingName) nameProgress(),
        if (nameErrorMessage.isNotEmpty) nameInputError(),
        passwordInput(),
        confirmPasswordInput(),
        validationButton(),
        alreadyHaveAccountButton(),
      ],
    );
  }

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
    );
  }

  Widget nameInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: usernameNode,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person_outline,
                ),
                labelText: 'Username',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) async {
                setState(() {
                  username = value;
                  isCheckingName = true;
                });

                final isWellFormatted = checkUsernameFormat(username);

                if (!isWellFormatted) {
                  setState(() {
                    isCheckingName = false;
                    nameErrorMessage = username.length < 3
                        ? 'Please use at least 3 characters'
                        : 'Please use alpha-numerical (A-Z, 0-9) characters and underscore (_)';
                  });

                  return;
                }

                if (nameTimer != null) {
                  nameTimer.cancel();
                  nameTimer = null;
                }

                nameTimer = Timer(1.seconds, () async {
                  final isAvailable = await checkUsernameAvailability(username);

                  if (!isAvailable) {
                    setState(() {
                      isCheckingName = false;
                      nameErrorMessage = 'This name is not available';
                    });

                    return;
                  }

                  setState(() {
                    isCheckingName = false;
                    nameErrorMessage = '';
                  });
                });
              },
              onFieldSubmitted: (_) => passwordNode.requestFocus(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'name cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget nameInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(nameErrorMessage,
          style: TextStyle(
            color: Colors.red.shade300,
          )),
    );
  }

  Widget nameProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: passwordNode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.length == 0) {
                  return;
                }
                password = value;
              },
              onFieldSubmitted: (_) => confirmPasswordNode.requestFocus(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Password cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget confirmPasswordInput() {
    return FadeInY(
      delay: 400.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: confirmPasswordNode,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: 'Confirm password',
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.length == 0) {
                  return;
                }
                confirmPassword = value;
              },
              onFieldSubmitted: (value) => signUpProcess(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Confirm password cannot be empty';
                }

                if (confirmPassword != password) {
                  return "Passwords don't match";
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 500.milliseconds,
      beginY: 50.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: RaisedButton(
            onPressed: () => signUpProcess(),
            color: stateColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
            child: Container(
              width: 250.0,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget alreadyHaveAccountButton() {
    return FadeInY(
      delay: 700.milliseconds,
      beginY: 50.0,
      child: Center(
        child: FlatButton(
            onPressed: () => context.router.navigate(SigninRoute()),
            child: Opacity(
              opacity: .6,
              child: Text(
                "I already have an account",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )),
      ),
    );
  }

  void ensureNotConnected() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await stateUser.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home()));
      }
    } catch (error) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  void signUpProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isSigningUp = true;
    });

    if (!await valuesAvailabilityCheck()) {
      setState(() {
        isSigningUp = false;
      });

      showSnack(
        context: context,
        message: 'The email or name entered is not available.',
        type: SnackType.error,
      );

      return;
    }

    // ?NOTE: Triming because of TAB key on Desktop insert blank spaces.
    email = email.trim();
    password = password.trim();

    try {
      final respCreateAcc = await createAccount(
        email: email,
        username: username,
        password: password,
      );

      if (!respCreateAcc.success) {
        final exception = respCreateAcc.error;

        setState(() {
          isSigningUp = false;
        });

        showSnack(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
          type: SnackType.error,
        );

        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isSigningUp = false;
      isCompleted = true;

      appStorage.setCredentials(
        email: email,
        password: password,
      );

      stateUser.setUserConnected();
      PushNotifications.linkAuthUser(respCreateAcc.user.id);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Home(),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isSigningUp = false;
      });

      showSnack(
        context: context,
        message: "An occurred while creating your account. " +
            "Please try again or contact us if the problem persists.",
        type: SnackType.error,
      );
    }
  }

  Future<bool> valuesAvailabilityCheck() async {
    final isEmailOk = await checkEmailAvailability(email);
    final isNameOk = await checkUsernameAvailability(username);

    return isEmailOk && isNameOk;
  }

  bool inputValuesOk() {
    if (password.isEmpty || confirmPassword.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    if (confirmPassword != password) {
      showSnack(
        context: context,
        message: "Password & confirm passwords don't match",
        type: SnackType.error,
      );

      return false;
    }

    if (username.isEmpty) {
      showSnack(
        context: context,
        message: "Name cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    if (!checkEmailFormat(email)) {
      showSnack(
        context: context,
        message: "The value specified is not a valid email",
        type: SnackType.error,
      );

      return false;
    }

    if (!checkUsernameFormat(username)) {
      showSnack(
        context: context,
        message: username.length < 3
            ? 'Please use at least 3 characters'
            : 'Please use alpha-numerical (A-Z, 0-9) characters and underscore (_)',
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }
}
