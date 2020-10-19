import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/app_icon.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/screens/home/home.dart';
import 'package:memorare/screens/signin.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

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

  Timer emailTimer;
  Timer nameTimer;

  bool isCheckingAuth = false;
  bool isCompleted = false;
  bool isSigningUp = false;

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();
  final confirmPasswordNode = FocusNode();

  @override
  initState() {
    super.initState();
    ensureNotConnected();
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
              AppIcon(
                padding: const EdgeInsets.only(top: 30.0, bottom: 60.0),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 300.0,
                ),
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
                child: Text('Create a new account'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget idleContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        header(),
        emailInput(),
        if (isCheckingEmail) emailProgress(),
        if (emailErrorMessage.isNotEmpty) emailInputError(),
        nameInput(),
        if (isCheckingName) nameProgress(),
        if (nameErrorMessage.isNotEmpty) nameInputError(),
        passwordInput(),
        confirmPasswordInput(),
        validationButton(),
        alreadyHaveAccountButton(),
      ],
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

  Widget nameInput() {
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
                icon: Icon(
                  Icons.person_outline,
                ),
                labelText: 'Username',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) async {
                setState(() {
                  username = value;
                  isCheckingName = true;
                });

                final isWellFormatted = checkUsernameFormat(username);

                if (!isWellFormatted) {
                  setState(() {
                    isCheckingName = false;
                    nameErrorMessage = username.length < 3
                        ? 'Please use at least 3 characters'
                        : 'Please use alpha-numerical (A-Z, 0-9) characters and underscore (_)';
                  });

                  return;
                }

                if (nameTimer != null) {
                  nameTimer.cancel();
                  nameTimer = null;
                }

                nameTimer = Timer(1.seconds, () async {
                  final isAvailable = await checkNameAvailability(username);

                  if (!isAvailable) {
                    setState(() {
                      isCheckingName = false;
                      nameErrorMessage = 'This name is not available';
                    });

                    return;
                  }

                  setState(() {
                    isCheckingName = false;
                    nameErrorMessage = '';
                  });
                });
              },
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

  Widget nameInputError() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 40.0,
      ),
      child: Text(nameErrorMessage,
          style: TextStyle(
            color: Colors.red.shade300,
          )),
    );
  }

  Widget nameProgress() {
    return Container(
      padding: const EdgeInsets.only(
        left: 40.0,
      ),
      child: LinearProgressIndicator(),
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
                if (value.length == 0) {
                  return;
                }
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
                if (value.length == 0) {
                  return;
                }
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: RaisedButton(
            onPressed: () => createAccount(),
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
                    'SIGN UP',
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
                  ),
                ],
              ),
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
      child: Center(
        child: FlatButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Signin()));
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                "I already have an account",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )),
      ),
    );
  }

  void ensureNotConnected() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await userState.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home()));
      }
    } catch (error) {
      setState(() {
        isCheckingAuth = false;
      });
    }
  }

  void createAccount() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isSigningUp = true;
    });

    if (!await valuesAvailabilityCheck()) {
      setState(() {
        isSigningUp = false;
      });

      showSnack(
        context: context,
        message: 'The email or name entered is not available.',
        type: SnackType.error,
      );

      return;
    }

    try {
      // ?NOTE: Triming because of TAB key on Desktop.
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;

      if (user == null) {
        setState(() {
          isSigningUp = false;
        });

        showSnack(
          context: context,
          message:
              'An occurred while creating your account. Please try again or contact us if the problem persists.',
          type: SnackType.error,
        );

        return;
      }

      final name = username.isNotEmpty
          ? username
          : email.substring(0, email.indexOf('@'));

      final userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = name;

      await user.updateProfile(userUpdateInfo);

      await Firestore.instance.collection('users').document(user.uid).setData({
        'email': user.email,
        'flag': '',
        'lang': 'en',
        'name': name,
        'nameLowerCase': name,
        'pricing': 'free',
        'quota': {
          'current': 0,
          'date': DateTime.now(),
          'limit': 1,
        },
        'rights': {
          'user:managedata': false,
          'user:manageauthor': false,
          'user:managequote': false,
          'user:managequotidian': false,
          'user:managereference': false,
          'user:proposequote': true,
          'user:readquote': true,
          'user:validatequote': false,
        },
        'stats': {
          'favourites': 0,
          'lists': 0,
          'proposed': 0,
        },
        'urls': {
          'image': 'local:user',
        },
        'uid': user.uid,
      });

      appLocalStorage.setCredentials(
        email: email,
        password: password,
      );

      userState.setUserConnected();

      isSigningUp = false;
      isCompleted = true;

      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home()));
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isSigningUp = false;
      });

      showSnack(
        context: context,
        message:
            'An occurred while creating your account. Please try again or contact us if the problem persists.',
        type: SnackType.error,
      );
    }
  }

  Future<bool> valuesAvailabilityCheck() async {
    final isEmailOk = await checkEmailAvailability(email);
    final isNameOk = await checkNameAvailability(username);

    return isEmailOk && isNameOk;
  }

  bool inputValuesOk() {
    if (password.isEmpty || confirmPassword.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

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

    if (!checkEmailFormat(email)) {
      showSnack(
        context: context,
        message: "The value specified is not a valid email",
        type: SnackType.error,
      );

      return false;
    }

    if (!checkUsernameFormat(username)) {
      showSnack(
        context: context,
        message: username.length < 3
            ? 'Please use at least 3 characters'
            : 'Please use alpha-numerical (A-Z, 0-9) characters and underscore (_)',
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }
}
