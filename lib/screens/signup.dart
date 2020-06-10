import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import'package:memorare/components/loading_animation.dart';
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
  String confirmPassword = '';
  String username = '';

  bool isEmailAvailable = true;
  bool isNameAvailable = true;

  String emailErrorMessage = '';
  String nameErrorMessage = '';

  bool isCheckingEmail = false;
  bool isCheckingName = false;

  bool isCheckingAuth = false;
  bool isCompleted    = false;
  bool isSigningUp    = false;

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();
  final confirmPasswordNode = FocusNode();

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
    return Scaffold(
      body: ListView(
        children: [
          Column(
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
          ),
        ],
      ),
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
      delay: .5,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 60.0),
        child: TextFormField(
          autofocus: true,
          onFieldSubmitted: (_) => usernameNode.nextFocus(),
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

            final wellFormatted = checkEmailFormat();

            if (!wellFormatted) {
              setState(() {
                isCheckingEmail = false;
                emailErrorMessage = 'The value is not a valid email address';
              });

              return;
            }

            final isAvailable = await checkEmailAvailability();

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
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Email cannot be empty';
            }

            return null;
          },
        ),
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

  Widget header() {
    return Column(
      children: <Widget>[
        FadeInY(
          beginY: 50.0,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Sign Up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        FadeInY(
          delay: .3,
          beginY: 50.0,
          child: Opacity(
            opacity: .6,
            child: Text(
              'Create a new account'
            ),
          ),
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),

        if (isCheckingEmail)
          emailProgress(),

        if (emailErrorMessage.isNotEmpty)
          emailInputError(),

        usernameInput(),
        passwordInput(),
        confirmPasswordInput(),
        validationButton(),
        alreadyHaveAccountButton(),
      ],
    );
  }

  Widget emailProgress() {
    return Container(
      padding: const EdgeInsets.only(left: 40.0,),
      child: LinearProgressIndicator(),
    );
  }

  Widget usernameInput() {
    return FadeInY(
      delay: 1.0,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: usernameNode,
              decoration: InputDecoration(
                icon: Icon(Icons.person_outline,),
                labelText: 'Username',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) => username = value,
              onFieldSubmitted: (_) => passwordNode.nextFocus(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'name cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 1.5,
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
                  return 'Password cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget confirmPasswordInput() {
    return FadeInY(
      delay: 2.0,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: confirmPasswordNode,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: 'Confirm password',
              ),
              obscureText: true,
              onChanged: (value) {
                if (value.length == 0) { return; }
                confirmPassword = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Confirm password cannot be empty';
                }

                if (confirmPassword != password) {
                  return "Passwords don't match";
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
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: RaisedButton(
          onPressed: () {
            createAccount();
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('SIGN UP'),
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

  Widget alreadyHaveAccountButton() {
    return FadeInY(
      delay: 3.0,
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
            "I already have an account",
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        )
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

  bool checkEmailFormat() {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
      .hasMatch(email);
  }

  Future<bool> checkEmailAvailability() async {
    try {
      final callable = CloudFunctions(
        app: FirebaseApp.instance,
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'users-checkEmailAvailability',
      );

      final resp = await callable.call({'email': email});
      final isOk = resp.data['isAvailable'] as bool;
      return isOk;

    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  void createAccount() async {
    final isOk = valuesChecks();
    if (!isOk) { return; }

    setState(() {
      isSigningUp = true;
    });

    try {
      // ?NOTE: Triming because of TAB key on Desktop.
      final result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email.trim(), password: password.trim());

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
          'pricing': 'free',
          'quota': {
            'current': 0,
            'date': DateTime.now(),
            'limit': 1,
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

  bool valuesChecks() {
    if (confirmPassword != password) {
      showSnack(
        context: context,
        message: "Password & confirm passwords don't match",
        type: SnackType.error,
      );

      return false;
    }

    if (username.isEmpty) {
      showSnack(
        context: context,
        message: "Name cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }
}
