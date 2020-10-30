import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/types/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
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

  final beginY = 30.0;
  final passwordNode = FocusNode();

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          PageAppBar(
            textTitle: 'Update email',
            textSubTitle: 'If your email is outdated',
            expandedHeight: 170.0,
          ),
          body(),
        ],
      ),
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
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          width: 400.0,
          child: Column(
            children: <Widget>[
              FadeInY(
                delay: 0.0,
                beginY: beginY,
                child: currentEmailCard(),
              ),
              FadeInY(
                delay: 0.1,
                beginY: beginY,
                child: emailInput(),
              ),
              FadeInY(
                delay: 0.2,
                beginY: beginY,
                child: passwordInput(),
              ),
              FadeInY(
                delay: 0.3,
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
    );
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          width: 400.0,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Icon(
                  Icons.check_circle,
                  size: 80.0,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
                child: Text(
                  'Your email has been successfuly updated.',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
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
        top: 60.0,
        bottom: 40.0,
      ),
      child: Card(
        elevation: 2.0,
        child: InkWell(
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
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
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
          child: Container(
            width: 250.0,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.alternate_email),
                    ),
                    Opacity(
                      opacity: .7,
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
        ),
      ),
    );
  }

  Widget emailInput() {
    return SizedBox(
      width: 350.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: passwordNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Password',
            ),
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
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
              CircularProgressIndicator(),
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
    return OutlinedButton(
      onPressed: () => updateEmail(),
      style: OutlinedButton.styleFrom(
        primary: stateColors.primary,
      ),
      child: SizedBox(
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
      final userAuth = await userState.userAuth;

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

  void updateEmail() async {
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

      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isUpdating = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email,
        password: password,
      );

      final authResult =
          await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user.updateEmail(email);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user.uid)
          .update({
        'email': email,
      });

      userState.clearAuthCache();

      setState(() {
        isUpdating = false;
        isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isUpdating = false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
            'Error while updating your email. Please try again or contact us.'),
      ));
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
