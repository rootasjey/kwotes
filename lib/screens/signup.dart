import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/push_notifications.dart';
import 'package:memorare/utils/snack.dart';

class Signup extends StatefulWidget {
  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  bool isLoading    = false;
  bool isCompleted  = false;
  double beginY     = 100.0;

  bool arePasswordsEqual = true;

  String confirmPassword  = '';
  String email            = '';
  String name             = '';
  String password         = '';
  String username         = '';

  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  final confirmPasswordNode = FocusNode();

  @override
  void dispose() {
    emailNode.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: stateColors.primary,
          leading: Padding(
            padding: const EdgeInsets.only(top: 17.0),
            child: IconButton(
              onPressed: () => FluroRouter.router.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Sign up',
            ),
          ),
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: LoadingComponent(
          title: 'Creating your account...',
        ),
      );
    }

    if (isCompleted) {
      return completedScreen();
    }

    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Form(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: <Widget>[
                    FadeInY(
                      delay: 1.0,
                      beginY: beginY,
                      child: subtitle(),
                    ),

                    FadeInY(
                      delay: 2.0,
                      beginY: beginY,
                      child: usernameInput(),
                    ),

                    FadeInY(
                      delay: 3.0,
                      beginY: beginY,
                      child: emailInput(),
                    ),

                    FadeInY(
                      delay: 4.0,
                      beginY: beginY,
                      child: passwordInput(),
                    ),

                    FadeInY(
                      delay: 5.0,
                      beginY: beginY,
                      child: confirmPasswordInput(),
                    ),

                    FadeInY(
                      delay: 6.0,
                      beginY: beginY,
                      child: signInButton(),
                    ),

                    FadeInY(
                      delay: 7.0,
                      beginY: beginY,
                      child: validationButton(),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget completedScreen() {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Icon(
              Icons.check_circle,
              color: stateColors.primary,
              size: 90.0,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 30.0),
            child: Text(
              'Your account has been successfully created!',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Opacity(
            opacity: .7,
            child: Text(
              'Check your mail box and your spam folder to validate your account.',
              style: TextStyle(fontSize: 20.0),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 60),
            child: FlatButton(
              color: stateColors.primary,
              onPressed: () {
                FluroRouter.router.navigateTo(context, HomeRoute);
              },
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(right: 10.0), child: Icon(Icons.check, color: Colors.white,),),
                    Text('Alright', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget confirmPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: confirmPasswordNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: stateColors.primary,),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: stateColors.primary,),
              ),
              labelText: 'Confirm password',
              labelStyle: TextStyle(color: stateColors.primary,),
            ),
            obscureText: true,
            onChanged: (value) {
              confirmPassword = value;

              if (confirmPassword != password) { arePasswordsEqual = false; }
              else { arePasswordsEqual = true; }
            },
            onFieldSubmitted: (_) => createAccount(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Password cannot be empty';
              }

              if (value != password) {
                return "Both passwords entered don't match";
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget emailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: emailNode,
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: stateColors.primary),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: stateColors.primary,),
              ),
              labelText: 'Email',
              labelStyle: TextStyle(color: stateColors.primary,),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (value) => email = value,
            onFieldSubmitted: (_) => emailNode.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Email cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget signInButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: FlatButton(
        onPressed: () {
          FluroRouter.router.navigateTo(context, SigninRoute);
        },
        child: Text(
          "I already have an account"
        ),
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            focusNode: passwordNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline, color: stateColors.primary,),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: stateColors.primary,),
              ),
              labelText: 'Password',
              labelStyle: TextStyle(color: stateColors.primary,),
            ),
            obscureText: true,
            textInputAction: TextInputAction.go,
            onChanged: (value) => password = value,
            onFieldSubmitted: (_) => confirmPasswordNode.requestFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Password cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget subtitle() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        'Sign up to a new account.',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget usernameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            decoration: InputDecoration(
              icon: Icon(Icons.person_outline, color: stateColors.primary),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: stateColors.primary,),
              ),
              labelText: 'Username',
              labelStyle: TextStyle(color: stateColors.primary,),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) => username = value,
            onFieldSubmitted: (_) => emailNode.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Username cannot be empty';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget validationButton() {
    return Padding(
      padding: EdgeInsets.only(top: 100.0),
      child: FlatButton(
        onPressed: () => createAccount(),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: stateColors.primary),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.arrow_forward,),
              )
            ],
          )
        ),
      ),
    );
  }

  void createAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ?NOTE: Triming because of TAB key on Desktop.
      final result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email.trim(), password: password.trim());

      final user = result.user;

      if (user == null) {
        throw Error();
      }

      final userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = username;

      user.updateProfile(userUpdateInfo);

      await Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData({
          'email': user.email,
          'flag': '',
          'lang': 'en',
          'name': username,
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

        appLocalStorage.saveCredentials(
          email: email,
          password: password,
        );

        appLocalStorage.saveUserName(username);
        appLocalStorage.saveUserUid(user.uid);

        userState.setUserConnected();

        setState(() {
          isCompleted = true;
          isLoading = false;
        });

        if (Platform.isAndroid || Platform.isIOS) {
          PushNotifications.initialize(
            context: context,
            userUid: user.uid,
          );
        }

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });

      showSnack(
        context: context,
        message: 'An ocurred while creating your account. Try again later or contact us',
        type: SnackType.error,
      );
    }
  }
}
