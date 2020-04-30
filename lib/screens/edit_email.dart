import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/utils/snack.dart';

class EditEmail extends StatefulWidget {
  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  String email      = '';
  String password   = '';

  bool isUpdating   = false;
  bool isCompleted  = false;

  final beginY    = 100.0;
  final delay     = 1.0;
  final delayStep = 1.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 1,
            title: Text(
              'Update email',
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back,),
            ),
          ),
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedScreen();
    }

    if (isUpdating) {
      return updatingScreen();
    }

    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: <Widget>[
        Column(
          children: <Widget>[
            FadeInY(
              delay: delay + (1 * delayStep),
              beginY: beginY,
              child: imageTitle(),
            ),

            FadeInY(
              delay: delay + (2 * delayStep),
              beginY: beginY,
              child: emailInput(),
            ),

            FadeInY(
              delay: delay + (3 * delayStep),
              beginY: beginY,
              child: passwordInput(),
            ),

            FadeInY(
              delay: delay + (4 * delayStep),
              beginY: beginY,
              child: validationButton(),
            ),

            Padding(padding: const EdgeInsets.only(bottom: 200.0),),
          ],
        ),
      ],
    );
  }

  Widget completedScreen() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Icon(
              Icons.check_circle_outline,
              size: 80.0,
              // color: Colors.green,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0,),
            child: Text(
              'Your email has been successfuly updated!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0,),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Check your inbox to validate your email. It may be in the junk folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emailInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: 'Enter your new email',
            ),
            onChanged: (value) {
              email = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'New email cannot be empty';
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

  Widget passwordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Entering your password',
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
      ),
    );
  }

  Widget updatingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

  Widget buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: FlatButton(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: ThemeColor.success,
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    updateEmail();
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget completionScreen() {
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
              color: ThemeColor.success,
              size: 90.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
            child: Text(
              'We\'ve sent you an email to your new address. Go to your inbox and click on the link to validate it.',
              style: TextStyle(fontSize: 25.0),
            ),
          ),

          Text(
            'Do not forget to check your spam folder if you do not see the email.',
            style: TextStyle(fontSize: 20.0),
          ),

          Padding(
            padding: EdgeInsets.only(top: 60),
            child: FlatButton(
              color: ThemeColor.success,
              onPressed: () { Navigator.of(context).pop(true); },
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(right: 10.0), child: Icon(Icons.check, color: Colors.white,),),
                    Text('Will check', style: TextStyle(color: Colors.white, fontSize: 20.0),),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: FlatButton(
              onPressed: () {
                setState(() { isCompleted = false; });
              },
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text('Try another email', style: TextStyle(fontSize: 20.0),),
              ),
            ),
          ),
        ],
      ),
    );
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

      setState(() {
        isUpdating = false;
        isCompleted = true;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isUpdating = false;
      });

      showSnack(
        context: context,
        message: 'Error while updating your email. Please try again or contact us.',
        type: SnackType.error,
      );
    }
  }
}
