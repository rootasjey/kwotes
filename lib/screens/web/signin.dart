import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = '';
  String password = '';

  bool isCheckingAuth = false;
  bool isCompleted    = false;
  bool isSigningIn    = false;

  final _passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        Padding(
        padding: const EdgeInsets.only(bottom: 300.0),
        child: SizedBox(
          width: 300.0,
          child: body(),
        ),
      ),
      ],
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedContainer();
    }

    if (isSigningIn) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          title: 'Signing in...',
        ),
      );
    }

    return idleContainer();
  }

  Widget completedContainer() {
    return Column(
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
            'You are now logged in!',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 15.0,),
          child: FlatButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                DashboardRoute,
              );
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                'Go to your dashboard',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        formHeader(),
        emailInput(),
        passwordInput(),
        validationButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 1.5,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
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

  Widget formHeader() {
    return Column(
      children: <Widget>[
        FadeInY(
          beginY: 50.0,
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Sign in into your existing account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        FadeInY(
          delay: 1,
          beginY: 50.0,
          child: FlatButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                SignupRoute,
              );
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                "I don't have an account"
              ),
            )
          ),
        ),
      ],
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 2,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: _passwordNode,
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
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 2,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: FlatButton(
          onPressed: () {
            signIn();
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Sign me in'),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(Icons.arrow_forward),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final user = await getUserAuth();

      setState(() {
        isCheckingAuth = false;
      });

      if (user != null) {
        userState.setUserConnected();
        FluroRouter.router.navigateTo(context, DashboardRoute);
      }

    } catch (error) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  void showSnack({String message}) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      )
    );
  }

  void signIn() async {
    setState(() {
      isSigningIn = true;
    });

    try {
      final result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

      if (result.user == null) {
        showSnack(message: 'The password is incorrect or the user does not exists.');
        return;
      }

      appLocalStorage.saveCredentials(
        email: email,
        password: password,
      );

      setState(() {
        isSigningIn = false;
        isCompleted = true;
      });

      final lang = await Language.fetch(result.user);
      Language.setLang(lang);

      userState.setUserConnected();

    } catch (error) {
      debugPrint(error.toString());

      showSnack(
        message: 'The password is incorrect or the user does not exists.',
      );

      setState(() {
        isSigningIn = false;
      });
    }
  }
}
