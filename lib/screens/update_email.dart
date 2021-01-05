import 'dart:async';

import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class UpdateEmail extends StatefulWidget {
  @override
  _UpdateEmailState createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  bool isCheckingEmail = false;
  bool isEmailAvailable = false;
  bool isCheckingAuth = false;
  bool isUpdating = false;
  bool isCompleted = false;

  final beginY = 10.0;
  final passwordNode = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String currentEmail = '';
  String email = '';
  String emailErrorMessage = '';
  String password = '';

  Timer emailTimer;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    passwordNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar(),
          body(),
        ],
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
    }

    return PageAppBar(
      textTitle: 'Update email',
      textSubTitle: 'If your email is outdated',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      expandedHeight: 90.0,
      showNavBackIcon: true,
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedView();
    }

    if (isUpdating) {
      return updatingView();
    }

    return idleView();
  }

  Widget idleView() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            width: 400.0,
            child: Column(
              children: <Widget>[
                FadeInY(
                  delay: 0.milliseconds,
                  beginY: beginY,
                  child: currentEmailCard(),
                ),
                FadeInY(
                  delay: 100.milliseconds,
                  beginY: beginY,
                  child: emailInput(),
                ),
                FadeInY(
                  delay: 200.milliseconds,
                  beginY: beginY,
                  child: passwordInput(),
                ),
                FadeInY(
                  delay: 300.milliseconds,
                  beginY: beginY,
                  child: validationButton(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 200.0),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          width: 400.0,
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Icon(
                  Icons.check,
                  size: 80.0,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                child: Text(
                  'Your email has been successfuly updated',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Go back"),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget currentEmailCard() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 40.0,
      ),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          child: Container(
            width: 300.0,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Opacity(
                          opacity: 0.6,
                          child: Icon(
                            Icons.alternate_email,
                            color: stateColors.secondary,
                          )),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Current email',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: Text(
                        currentEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(
                      'This is your current email',
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    children: <Widget>[
                      Divider(
                        color: stateColors.secondary,
                        thickness: 1.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                        ),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            currentEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  Widget emailInput() {
    return Container(
      width: 350.0,
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: emailController,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => passwordNode.requestFocus(),
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: 'New email',
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
            validator: (value) {
              if (value.isEmpty) {
                return 'Email cannot be empty';
              }

              return null;
            },
          ),
          if (isCheckingEmail) emailProgress(),
          if (emailErrorMessage.isNotEmpty) emailInputError(),
        ],
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

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return Container(
      width: 350.0,
      padding: EdgeInsets.only(
        top: 20.0,
        bottom: 60.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: passwordNode,
            controller: passwordController,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Password',
            ),
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            onFieldSubmitted: (value) => updateEmailProcess(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Password login cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget updatingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          width: 400.0,
          child: Column(
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Updating your email...',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget validationButton() {
    return OutlinedButton.icon(
      onPressed: () => updateEmailProcess(),
      style: OutlinedButton.styleFrom(
        primary: stateColors.primary,
      ),
      icon: Icon(Icons.check),
      label: SizedBox(
        width: 240.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'UPDATE EMAIL',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await stateUser.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
      }

      setState(() {
        currentEmail = userAuth.email;
      });
    } catch (error) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
    }
  }

  void updateEmailProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      if (!await valuesAvailabilityCheck()) {
        setState(() {
          isUpdating = false;
        });

        showSnack(
          context: context,
          message: 'The email entered is not available.',
          type: SnackType.error,
        );

        return;
      }

      final userAuth = await stateUser.userAuth;

      if (userAuth == null) {
        setState(() {
          isUpdating = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => Signin(),
          ),
        );

        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);
      final idToken = await userAuth.getIdToken();

      final respUpdateEmail = await updateEmail(email, idToken);

      if (!respUpdateEmail.success) {
        final exception = respUpdateEmail.error;

        setState(() {
          isUpdating = false;
        });

        showSnack(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
          type: SnackType.error,
        );

        return;
      }

      stateUser.clearAuthCache();

      setState(() {
        isUpdating = false;
        isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isUpdating = false;
      });

      showSnack(
        context: context,
        message:
            "Error while updating your email. Please try again later or contact us.",
        type: SnackType.error,
      );
    }
  }

  Future<bool> valuesAvailabilityCheck() async {
    return await checkEmailAvailability(email);
  }

  bool inputValuesOk() {
    if (email.isEmpty) {
      showSnack(
        context: context,
        message: "Email cannot be empty.",
        type: SnackType.error,
      );

      return false;
    }

    if (password.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty.",
        type: SnackType.error,
      );

      return false;
    }

    if (!checkEmailFormat(email)) {
      showSnack(
        context: context,
        message: "The value specified is not a valid email.",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }
}
