import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class EditPassword extends StatefulWidget {
  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  String password = '';
  String newPassword = '';

  FirebaseUser userAuth;

  bool isCheckingAuth = false;
  bool isUpdating     = false;
  bool isCompleted    = false;

  double beginY   = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
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
            delay: delay + (3 * delayStep),
            beginY: beginY,
            child: currentPasswordInput(),
          ),

          FadeInY(
            delay: delay + (4 * delayStep),
            beginY: beginY,
            child: newPasswordInput(),
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
              'Your password has been successfuly updated.',
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

  Widget currentPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_open),
              labelText: 'Enter your current password',
            ),
            onChanged: (value) {
              password = value;
            },
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

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 70.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/lock-${stateColors.iconExt}.png',
        width: 100.0,
      ),
    );
  }

  Widget newPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, bottom: 80.0,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Enter your new password',
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
    return SizedBox(
      width: 400.0,
      child: Column(
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
    );
  }

  Widget validationButton() {
    return RaisedButton(
      onPressed: () {
        updatePassword();
      },
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: stateColors.primary,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          'Update',
        ),
      )
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      userAuth = await getUserAuth();

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

    } catch (error) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }


  }

  void updatePassword() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      final authResult = await userAuth.reauthenticateWithCredential(credentials);

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

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while updating your email. Please try again or contact us.'),
        )
      );
    }
  }
}
