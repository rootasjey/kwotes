import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/loading_animation.dart';
import 'package:figstyle/screens/forgot_password.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/signup.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/snack.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = '';
  String password = '';

  bool isCheckingAuth = false;
  bool isCompleted = false;
  bool isSigningIn = false;

  final passwordNode = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ensureNotConnected();
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
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
                  width: 320.0,
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
    if (isSigningIn) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          textTitle: 'Signing in...',
        ),
      );
    }

    return idleContainer();
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        passwordInput(),
        forgotPassword(),
        validationButton(),
        noAccountButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 0.5,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 80.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              onFieldSubmitted: (value) => passwordNode.requestFocus(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Email login cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return FadeInY(
      delay: 1.5,
      beginY: 50.0,
      child: FlatButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ForgotPassword()));
          },
          child: Opacity(
            opacity: 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  "I forgot my password",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget header() {
    return Row(
      children: <Widget>[
        FadeInX(
          beginX: 10.0,
          delay: 2.0,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FadeInY(
              beginY: 50.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 0.3,
              beginY: 50.0,
              child: Opacity(
                opacity: .6,
                child: Text('Connect to your existing account'),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget noAccountButton() {
    return FadeInY(
      delay: 2.5,
      beginY: 50.0,
      child: FlatButton(
          onPressed: () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => Signup()));

            if (userState.isUserConnected) {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Home()));
            }
          },
          child: Opacity(
            opacity: .6,
            child: Text(
              "I don't have an account",
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          )),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 1.0,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 30.0,
          left: 15.0,
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
              onFieldSubmitted: (value) => signInProcess(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Password login cannot be empty';
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
      delay: 2.0,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: RaisedButton(
          onPressed: () => signInProcess(),
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
                  'SIGN IN',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void ensureNotConnected() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth != null) {
        userState.setUserConnected();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home()));
      }
    } catch (error) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  bool inputValuesOk() {
    if (!checkEmailFormat(email)) {
      showSnack(
        context: context,
        message: "The value specified is not a valid email",
        type: SnackType.error,
      );

      return false;
    }

    if (password.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }

  void signInProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isSigningIn = true;
    });

    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult.user == null) {
        showSnack(
          context: context,
          type: SnackType.error,
          message: 'The password is incorrect or the user does not exists.',
        );

        return;
      }

      appStorage.setCredentials(
        email: email,
        password: password,
      );

      userState.setUserConnected();

      isSigningIn = false;
      isCompleted = true;

      await userGetAndSetAvatarUrl(authResult);

      PushNotifications.linkAuthUser(authResult.user.uid);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Home(),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        context: context,
        type: SnackType.error,
        message: 'The password is incorrect or the user does not exists.',
      );

      setState(() {
        isSigningIn = false;
      });
    }
  }
}
