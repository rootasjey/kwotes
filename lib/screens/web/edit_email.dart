import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class EditEmail extends StatefulWidget {
  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  String email = '';
  String password = '';

  FirebaseUser userAuth;

  bool isCheckingAuth = false;
  bool isUpdating     = false;
  bool isCompleted    = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          NavBackHeader(),
          body(),
          NavBackFooter(),
        ],
      ),
    );
  }

  Widget body() {
    if (isCompleted) {
      return SizedBox(
        width: 600.0,
        child: Column(
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
                'Your email has been successfuly updated.',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),

            NavBackFooter(),
          ],
        ),
      );
    }
    if (isUpdating) {
      return SizedBox(
        width: 600.0,
        child: Column(
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

    return SizedBox(
      width: 600.0,
      child: Column(
        children: <Widget>[
          Text(
            'Update my email',
            style: TextStyle(
              fontSize: 35.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Enter my new email',
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
          ),

          Padding(
            padding: EdgeInsets.only(top: 50.0, bottom: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock_outline),
                    labelText: 'Confirm this action by entering your password',
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

          RaisedButton(
            color: Colors.green,
            onPressed: () {
              updateEmail();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Edit email',
                style: TextStyle(
                  color: Colors.white,
                )
              ),
            )
          ),
        ],
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      userAuth = await getUserAuth();

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
      }

    } catch (error) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void updateEmail() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      final authResult = await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user.updateEmail(email);

      await FirestoreApp.instance
        .collection('users')
        .doc(authResult.user.uid)
        .update(
          data: {
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

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while updating your email. Please try again or contact us.'),
        )
      );
    }
  }
}
