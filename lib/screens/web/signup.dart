import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = '';
  String password = '';
  bool isCompleted = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        Padding(
          padding: const EdgeInsets.only(bottom: 300.0),
          child: SizedBox(
            width: 300.0,
            child: content(),
          ),
        ),
      ],
    );
  }

  Widget content() {
    if (isCompleted) {
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
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 15.0,),
            child: FlatButton(
              onPressed: () {
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

    if (isLoading) {
      return Column(
        children: <Widget>[
          CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              'Signing up...',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          )
        ],
      );
    }

    return Column(
      children: <Widget>[
        Padding(
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

        FlatButton(
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

        Padding(
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
        Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
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

        Padding(
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
        )
      ],
    );
  }

  void createAccount() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

      final user = result.user;

      if (user == null) {
        setState(() {
          isLoading = false;
        });

        Scaffold.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'An occurred while creating your account. Please try again or contact us if the problem persists.',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        );

        return;
      }

      // Create user in firestore
      final doc = await FirestoreApp.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'uid': user.uid,
          'email': user.email,
          'lang': 'en',
          'name': '',
          'nameLowerCase': '',
          'notifications': [],
          'pricing': 'free',
          'quota': {
            'date': DateTime.now(),
            'history': [],
            'today': 0,
          },
          'rights': {
            'user:proposequote': true,
            'user:readquote': true,
          },
          'tokens': {},
        });

      setState(() {
        isLoading = true;
        isCompleted = true;
      });

    } catch (error) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${error.toString()}',
          ),
        )
      );
    }
  }
}
