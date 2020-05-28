import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/push_notifications.dart';
import 'package:memorare/utils/snack.dart';

class Signin extends StatefulWidget {
  @override
  SigninState createState() => SigninState();
}

class SigninState extends State<Signin> {
  final formKey   = GlobalKey<FormState>();
  bool isLoading  = false;
  double beginY   = 100.0;

  String email    = '';
  String password = '';

  final passwordNode = FocusNode();

  @override
  void dispose() {
    passwordNode.dispose();
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
              'Sign in',
            ),
          )
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    if (isLoading) {
      return LoadingAnimation(textTitle: 'Signing in...',);
    }

    return ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Form(
              key: formKey,
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
                      child: emailInput(),
                    ),

                    FadeInY(
                      delay: 3.0,
                      beginY: beginY,
                      child: passwordInput(),
                    ),

                    FadeInY(
                      delay: 4.0,
                      beginY: beginY,
                      child: signupButton(),
                    ),

                    FadeInY(
                      delay: 5.0,
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

  Widget emailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: stateColors.primary),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: stateColors.primary,),
              ),
              labelText: 'Email',
              labelStyle: TextStyle(color: stateColors.primary,),
            ),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            onFieldSubmitted: (_) => passwordNode.nextFocus(),
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

  Widget signupButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: FlatButton(
        onPressed: () {
          FluroRouter.router.navigateTo(context, SignupRoute);
        },
        child: Text(
          "I don't have an account"
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
            onFieldSubmitted: (value) => connectAccount(),
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
        'Sign in into your existing account.',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget validationButton() {
    return Padding(
      padding: EdgeInsets.only(top: 100.0),
      child: FlatButton(
        onPressed: () => connectAccount(),
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
                'Sign in',
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

  void connectAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

      if (authResult.user == null) {
        throw Error();
      }

      final userAuth = authResult.user;

      appLocalStorage.setCredentials(email: email, password: password);
      appLocalStorage.setUserName(userAuth.displayName);
      appLocalStorage.setUserUid(userAuth.uid);

      userState.setUserConnected();

      setState(() {
        isLoading = false;
      });

      await PushNotifications.saveDeviceToken(userAuth.uid);

      FluroRouter.router.navigateTo(context, HomeRoute);

    } catch (error) {
      setState(() {
        isLoading = false;
      });

      showSnack(
        context: context,
        message: 'Invalid email or password',
        type: SnackType.error,
      );
    }
  }
}
