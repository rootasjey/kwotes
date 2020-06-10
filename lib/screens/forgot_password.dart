import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/loading_animation.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = '';

  bool isCompleted = false;
  bool isLoading = false;

  final passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              NavBackHeader(),

              Padding(
                padding: const EdgeInsets.only(bottom: 300.0),
                child: SizedBox(
                  width: width > 500.0 ? 320.0 : width,
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

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: LoadingAnimation(
          textTitle: 'Sending email...',
        ),
      );
    }

    return idleContainer();
  }

  Widget completedContainer() {
    final width = MediaQuery.of(context).size.width;

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

        Container(
          width: width > 400.0 ? 320.0 : 280.0,
          // padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                child: Text(
                  "A password reset link has been sent to your mail box",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),

              Opacity(
                opacity: .6,
                child: Text(
                  'Please check your spam folder too'
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 55.0,),
          child: FlatButton(
            onPressed: () {
              FluroRouter.router.navigateTo(
                context,
                RootRoute,
              );
            },
            child: Opacity(
              opacity: .6,
              child: Text(
                'Return to home',
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
        validationButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 1.5,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 40.0,
          left: 15.0,
        ),
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
    return FadeInY(
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          'Enter your email. We will send a reset link to your mail box.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 2,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: RaisedButton(
          onPressed: () {
            sendResetLink();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('SEND LINK'),
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

  void sendResetLink() async {
    try {
      setState(() {
        isLoading = true;
        isCompleted = false;
      });

      await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email);

      setState(() {
        isLoading = false;
        isCompleted = true;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });

      showSnack(
        context: context,
        type: SnackType.error,
        message: "Sorry, this email doesn't exist."
      );
    }
  }
}
