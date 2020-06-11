import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class EditEmail extends StatefulWidget {
  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  String currentEmail = '';
  String email = '';
  String password = '';

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
      body: ListView(
        children: <Widget>[
          NavBackHeader(),
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

    final width = MediaQuery.of(context).size.width;
    final inputWidth = width < 500.0 ? 260.0 : width;

    return SizedBox(
      width: 400.0,
      child: Column(
        children: <Widget>[
          FadeInY(
            delay: delay + (1 * delayStep),
            beginY: beginY,
            child: textTitle(),
          ),

          FadeInY(
            delay: delay + (2 * delayStep),
            beginY: beginY,
            child: imageTitle(),
          ),

          FadeInY(
            delay: delay + (2.5 * delayStep),
            beginY: beginY,
            child: emailButton(),
          ),

          FadeInY(
            delay: delay + (3 * delayStep),
            beginY: beginY,
            child: emailInput(width: inputWidth),
          ),

          FadeInY(
            delay: delay + (4 * delayStep),
            beginY: beginY,
            child: passwordInput(width: inputWidth),
          ),

          FadeInY(
            delay: delay + (5 * delayStep),
            beginY: beginY,
            child: validationButton(),
          ),

          Padding(padding: const EdgeInsets.only(bottom: 200.0),),
        ],
      ),
    );
  }

  Widget completedScreen() {
    return SizedBox(
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
    );
  }

  Widget emailButton() {
    return FlatButton(
      onPressed: () {
        FluroRouter.router.navigateTo(context, EditEmailRoute);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text('Email'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                  ),
                  child: Text(
                    currentEmail,
                    style: TextStyle(
                      color: stateColors.primary,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
      child: Opacity(
        opacity: .7,
        child: SizedBox(
          width: 250.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Icon(Icons.alternate_email),
              ),

              Text(
                currentEmail,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emailInput({double width}) {
    return Container(
      width: width ?? 400.0,
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: 'New email',
            ),
            onChanged: (value) {
              email = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'The email cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/write-email-${stateColors.iconExt}.png',
        width: 100.0,
      ),
    );
  }

  Widget passwordInput({double width}) {
    return Container(
      width: width ?? 400.0,
      padding: EdgeInsets.only(top: 50.0, bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Current password',
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

  Widget textTitle() {
    return Text(
      'Update email',
      style: TextStyle(
        fontSize: 35.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget updatingScreen() {
    return SizedBox(
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
    );
  }

  Widget validationButton() {
    return RaisedButton(
      onPressed: () {
        updateEmail();
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          'UPDATE EMAIL',
        ),
      )
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
    setState(() {
      isUpdating = true;
    });

    try {
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
}
