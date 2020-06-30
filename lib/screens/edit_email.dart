import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/sliver_app_header.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class EditEmail extends StatefulWidget {
  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  String currentEmail = '';
  String email = '';
  String password = '';

  final passwordNode = FocusNode();
  Timer emailTimer;

  bool isCheckingEmail = false;
  bool isEmailAvailable = false;
  String emailErrorMessage = '';

  bool isCheckingAuth = false;
  bool isUpdating     = false;
  bool isCompleted    = false;

  final beginY   = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

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
          SliverAppHeader(
            title: 'Update email',
            subTitle: 'If your email is outdated',
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
                delay: delay + (0 * delayStep),
                beginY: beginY,
                child: emailButton(),
              ),

              FadeInY(
                delay: delay + (.5 * delayStep),
                beginY: beginY,
                child: emailInput(),
              ),

              FadeInY(
                delay: delay + (1 * delayStep),
                beginY: beginY,
                child: passwordInput(),
              ),

              FadeInY(
                delay: delay + (2 * delayStep),
                beginY: beginY,
                child: validationButton(),
              ),

              Padding(padding: const EdgeInsets.only(bottom: 200.0),),
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

              NavBackFooter(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget emailButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Card(
        child: FlatButton(
          onPressed: () {
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
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                        top: 10.0,
                      ),
                      child: Text(
                        currentEmail,
                        style: TextStyle(
                          color: stateColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }
            );
          },
          child: Container(
            width: 250.0,
            padding: const EdgeInsets.all(8.0),
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
    return Container(
      width: 350.0,
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            onFieldSubmitted: (_) => passwordNode.requestFocus(),
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

              emailTimer = Timer(
                1.seconds,
                () async {
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

          if (isCheckingEmail)
            emailProgress(),

          if (emailErrorMessage.isNotEmpty)
            emailInputError(),
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
      child: Text(
        emailErrorMessage,
        style: TextStyle(
          color: Colors.red.shade300,
        )
      ),
    );
  }

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(left: 40.0,),
      child: LinearProgressIndicator(),
    );
  }

  Widget passwordInput() {
    return Container(
      width: 350.0,
      padding: EdgeInsets.only(
        top: 30.0,
        bottom: 120.0,
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
    return RaisedButton(
      color: stateColors.primary,
      onPressed: () => updateEmail(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      child: SizedBox(
        width: 240.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'UPDATE',
                style: TextStyle(
                  color: Colors.white,
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
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

      setState(() {
        currentEmail = userAuth.email;
      });

    } catch (error) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void updateEmail() async {
    if (!inputValuesOk()) { return; }

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

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      final authResult = await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user.updateEmail(email);

      await Firestore.instance
        .collection('users')
        .document(authResult.user.uid)
        .updateData({
            'email': email,
          }
        );

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

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while updating your email. Please try again or contact us.'),
        )
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
