import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class EditPassword extends StatefulWidget {
  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  String password = '';
  String newPassword = '';

  FirebaseUser userAuth;
  bool isLoading = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
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
                'Your password has been successfuly updated.',
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

    if (isLoading) {
      return SizedBox(
        width: 600.0,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Updating your password...',
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
            'Update my password',
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
                    labelText: 'Enter your current password',
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Current password cannot be empty';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 80.0,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Enter your new password',
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'New password cannot be empty';
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
              updatePassword();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Update my password',
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

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    setState(() {});

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void updatePassword() async {
    if (userAuth == null) {
      checkAuthStatus();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      final authResult = await userAuth.reauthenticateWithCredential(credentials);

      await authResult.user.updatePassword(newPassword);

      setState(() {
        isLoading = false;
        isCompleted = true;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
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
