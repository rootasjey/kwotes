import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/circle_button.dart';
import 'package:memorare/components/simple_appbar.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/snack.dart';

class UpdatePassword extends StatefulWidget {
  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  bool isCompleted = false;
  bool isUpdating = false;

  double beginY = 30.0;

  final newPasswordNode = FocusNode();

  String password = '';
  String newPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SimpleAppBar(
            expandedHeight: 90.0,
            title: Row(
              children: [
                CircleButton(
                    onTap: () => Navigator.of(context).pop(),
                    icon:
                        Icon(Icons.arrow_back, color: stateColors.foreground)),
                AppIconHeader(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  size: 30.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update password',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Opacity(
                        opacity: .6,
                        child: Text(
                          'If your password is old or compromised',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedScreen();
    }

    if (isUpdating) {
      return updatingScreen();
    }

    return idleView();
  }

  Widget completedScreen() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 80.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
                child: Text(
                  'Your password has been successfuly updated.',
                  textAlign: TextAlign.center,
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

  Widget currentPasswordInput() {
    return SizedBox(
      width: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_open),
              labelText: 'Current password',
            ),
            onChanged: (value) {
              password = value;
            },
            onFieldSubmitted: (_) => newPasswordNode.requestFocus(),
            obscureText: true,
            validator: (value) {
              if (value.isEmpty) {
                return 'Current password cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget helpCard() {
    return Container(
      padding: EdgeInsets.only(
        top: 60.0,
        left: 25.0,
        right: 25.0,
        bottom: 40.0,
      ),
      width: 500.0,
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Icon(Icons.help_outline),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(
                      'Recommandations',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // contentPadding: const EdgeInsets.all(25.0),
                    children: <Widget>[
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Choose at least a 6-characters password length",
                              style: TextStyle(),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 15.0)),
                            Text(
                              "Choose a pass-phrase",
                              style: TextStyle(),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 15.0)),
                            Text(
                              "Use special characters (e.g. *!#?)",
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          },
          title: Opacity(
            opacity: .6,
            child: Text(
              'Choosing a good password',
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Resist against over brute-force attacks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: <Widget>[
            FadeInY(
              delay: 0.0,
              beginY: beginY,
              child: helpCard(),
            ),
            FadeInY(
              delay: 0.1,
              beginY: beginY,
              child: currentPasswordInput(),
            ),
            FadeInY(
              delay: 0.2,
              beginY: beginY,
              child: newPasswordInput(),
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
      ]),
    );
  }

  Widget newPasswordInput() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: newPasswordNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'New password',
            ),
            obscureText: true,
            onChanged: (value) {
              newPassword = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'New password cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget textTitle() {
    return Text(
      'Update password',
      style: TextStyle(
        fontSize: 35.0,
      ),
    );
  }

  Widget updatingScreen() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Updating your password...',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
      ),
    ]));
  }

  Widget validationButton() {
    return OutlinedButton(
      onPressed: () {
        updatePassword();
      },
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

  void updatePassword() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isUpdating = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
        return;
      }

      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      final authResult =
          await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user.updatePassword(newPassword);

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
            'Error while updating your password. Please try again or contact us.',
        type: SnackType.error,
      );
    }
  }

  bool inputValuesOk() {
    if (password.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty.",
        type: SnackType.error,
      );

      return false;
    }

    if (newPassword.isEmpty) {
      showSnack(
        context: context,
        message: "New password cannot be empty.",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }
}
