import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/snack.dart';

class DeleteAccount extends StatefulWidget {
  @override
  DeleteAccountState createState() => DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  bool isDeleting   = false;
  bool isCompleted  = false;

  String password   = '';

  double beginY     = 100.0;
  final delay       = 1.0;
  final delayStep   = 1.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: AppBar(
            backgroundColor: stateColors.softBackground,
            centerTitle: true,
            elevation: 2,
            title: Text(
              'Delete account',
              style: TextStyle(
                fontSize: 25.0,
                color: stateColors.foreground,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: stateColors.foreground,
              ),
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

    if (isDeleting) {
      return deletingSceen();
    }

    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
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
              child: descriptionText(),
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
            padding: const EdgeInsets.only(top: 40.0),
            child: Icon(
              Icons.check_circle_outline,
              size: 80.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
            child: Text(
              'Your account has been successfuly deleted. \nWe hope to see you again.',
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
                  HomeRoute,
                );
              },
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Back to home',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget deletingSceen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              'Deleting your data...',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget descriptionText() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Opacity(
            opacity: .8,
            child: Text(
              'Are you sure you want to delete your account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                '• This action is irreversible\n• All your data will be whiped\n• Your published quotes will be kept',
                style: TextStyle(
                  fontSize: 18.0,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/delete-user-${stateColors.iconExt}.png',
        width: 100.0,
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.0, horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock_outline),
              labelText: 'Enter your password',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Text(
        'Delete account',
        style: TextStyle(
          fontSize: 35.0,
        ),
      ),
    );
  }

  Widget validationButton() {
    return RaisedButton(
      onPressed: () {
        deleteAccount();
      },
      color: stateColors.softBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: stateColors.primary,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          'Delete',
        ),
      )
    );
  }

  void deleteAccount() async {
    setState(() {
      isDeleting = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        setState(() {
          isDeleting = false;
        });

        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);

      await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .updateData({'flag': 'delete'});

      await userAuth.delete();

      setState(() {
        isDeleting = false;
        isCompleted = true;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isDeleting = false;
      });

      showSnack(
        context: context,
        message: 'Error while deleting your account. Please try again or contact us.',
        type: SnackType.error,
      );
    }
  }
}
