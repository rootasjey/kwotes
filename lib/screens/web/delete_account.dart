import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/auth.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  bool isDeleting     = false;
  bool isCompleted    = false;
  bool isCheckingAuth = false;

  FirebaseUser userAuth;
  String password = '';

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),
        body(),
        NavBackFooter(),
      ],
    );
  }

  Widget body() {
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
              'Your account has been successfuly deleted. \nWe hope to see you again.',
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
      );
    }

    if (isDeleting) {
      return Column(
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
      );
    }

    return SizedBox(
      width: 600.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Text(
              'Delete account',
              style: TextStyle(
                fontSize: 35.0,
              ),
            ),
          ),

          Card(
            elevation: 3,
            color: Color(0xFFF85C50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.warning,
                        size: 110.0,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Container(
                    child: Flexible(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Are you sure you want to delete your account?',
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.white,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Opacity(
                              opacity: .6,
                              child: Text(
                                'This action is irreversible. All your data will be whiped.',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 80.0),
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
            color: Colors.red,
            onPressed: () {
              deleteAccount();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Delete',
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
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void deleteAccount() async {
    setState(() {
      isDeleting = true;
    });

    try {
      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);

      await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .update(data: { 'flag': 'delete'});

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

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while deleting your account. Please try again or contact us.'),
        )
      );
    }
  }
}
