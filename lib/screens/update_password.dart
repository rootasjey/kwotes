import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/snack.dart';

class UpdatePassword extends StatefulWidget {
  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  bool isCompleted = false;
  bool isUpdating = false;

  double beginY = 10.0;

  final newPasswordNode = FocusNode();

  String password = '';
  String newPassword = '';

  @override
  void dispose() {
    newPasswordNode.dispose();
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
      textTitle: 'Update password',
      textSubTitle: 'If your password is old or compromised',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      bottomPadding: EdgeInsets.only(
        bottom: 10.0,
      ),
      showNavBackIcon: true,
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedView();
    }

    if (isUpdating) {
      return updatingScreen();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Icon(
                  Icons.check,
                  color: stateColors.validation,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      width: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.next,
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
        left: 25.0,
        top: 80.0,
        right: 25.0,
        bottom: 40.0,
      ),
      width: 500.0,
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Icon(
            Icons.help_outline,
            color: stateColors.secondary,
          ),
          title: Opacity(
            opacity: .6,
            child: Text(
              'Choosing a good password',
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Resist against brute-force attacks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
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
                    children: <Widget>[
                      Divider(
                        color: stateColors.secondary,
                        thickness: 1.0,
                      ),
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
        left: 40.0,
        right: 40.0,
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
            onFieldSubmitted: (value) => updatePassword(),
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
            AnimatedAppIcon(),
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
    return OutlinedButton.icon(
      onPressed: updatePassword,
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
                'UPDATE PASSWORD',
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

  void updatePassword() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
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

      final authResult =
          await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user.updatePassword(newPassword);
      appStorage.setPassword(newPassword);

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
            "Error while updating your password. Please try again or contact us.",
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
