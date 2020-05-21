import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/loading_animation.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = '';
  String password = '';

  bool isCheckingAuth = false;
  bool isCompleted    = false;
  bool isSigningUp    = false;

  final passwordNode = FocusNode();

  @override
  initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
    passwordNode.dispose();
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
            'Your account has been successfully created!',
            textAlign: TextAlign.center,
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
                  return 'Email cannot be empty';
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
              'Sign up for a new account.',
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
                SigninRoute,
              );
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                "I already have an account"
              ),
            )
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

  Widget passwordInput() {
    return FadeInY(
      delay: 2.0,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
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
                if (value.length == 0) { return; }
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
      delay: 2.5,
      beginY: 50.0,
      child: FadeInY(
        delay: 2.0,
        beginY: 50.0,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: FlatButton(
            onPressed: () {
              createAccount();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Sign me up'),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.arrow_forward),
                  )
                ],
              ),
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
      final userAuth = await userState.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth != null) {
        FluroRouter.router.navigateTo(context, DashboardRoute);
      }

    } catch (error) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  void createAccount() async {
    setState(() {
      isSigningUp = true;
    });

    try {
      final result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

      final user = result.user;

      if (user == null) {
        setState(() {
          isSigningUp = false;
        });

        showSnack(
          context: context,
          message: 'An occurred while creating your account. Please try again or contact us if the problem persists.',
          type: SnackType.error,
        );

        return;
      }

      await Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData({
          'email': user.email,
          'flag': '',
          'lang': 'en',
          'name': '',
          'nameLowerCase': '',
          'notifications': [],
          'pricing': 'free',
          'quota': {
            'day': DateTime.now(),
            'limit': 1,
            'today': 0,
          },
          'rights': {
            'user:managedata'     : false,
            'user:manageauthor'   : false,
            'user:managequote'    : false,
            'user:managequotidian': false,
            'user:managereference': false,
            'user:proposequote'   : true,
            'user:readquote'      : true,
            'user:validatequote'  : false,
          },
          'stats': {
            'favourites': 0,
            'lists': 0,
            'proposed': 0,
          },
          'tokens': {},
          'urls': {
            'image': '',
          },
          'uid': user.uid,
        });

      appLocalStorage.setCredentials(
        email: email,
        password: password,
      );

      setState(() {
        isSigningUp = true;
        isCompleted = true;
      });

    } catch (error) {
      debugPrint(error.toString());

      showSnack(
          context: context,
          message: 'An occurred while creating your account. Please try again or contact us if the problem persists.',
          type: SnackType.error,
        );
    }
  }
}
