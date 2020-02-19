import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/components/web/settings_card.dart';
import 'package:memorare/components/web/settings_color_card.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isLoading = false;
  bool isCompleted = false;
  FirebaseUser userAuth;

  String displayName = '';
  String oldDisplayName = '';
  String avatarUrl = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
      return;
    }

    setState(() {
      oldDisplayName = userAuth.displayName ?? '';
      avatarUrl = userAuth.photoUrl ?? '';
      email = userAuth.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 300.0),
      child: Column(
        children: <Widget>[
          NavBackHeader(),

          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 120.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'You can update your account settings here.',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ),

          avatar(),

          inputDisplayName(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: SizedBox(
              width: 500.0,
              child: Wrap(
                children: <Widget>[
                  SettingsCard(
                    icon: Icon(Icons.email, size: 40.0,),
                    name: 'Update email',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, EditEmailRoute);
                    },
                  ),

                  SettingsColorCard(
                    backgroundColor: Color(0xFFF85C50),
                    color: Colors.white,
                    icon: Icon(Icons.delete, size: 40.0, color: Colors.white,),
                    name: 'Delete account',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, DeleteAccountRoute);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget avatar() {
    NetworkImage networkImage;
    AssetImage assetImage = AssetImage('assets/images/icon-small.png');

    if (avatarUrl.length > 0) {
      networkImage = NetworkImage(avatarUrl);
    } else if (email.length > 0) {
      networkImage = NetworkImage('https://api.adorable.io/avatars/285/$email');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: Material(
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: networkImage != null ? NetworkImage('https://api.adorable.io/avatars/285/$email') :
            assetImage,
          fit: BoxFit.cover,
          width: 200.0,
          height: 200.0,
          child: InkWell(
            onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Container(
                        child: Image(
                          fit: BoxFit.cover,
                          image: networkImage ?? assetImage,
                        ),
                      ),
                    );
                  }
                );
              },
          ),
        ),
      ),
    );
  }

  Widget inputDisplayName() {
    if (isLoading) {
      return SizedBox(
        height: 200.0,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Updating your display name...'
              ),
            )
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(bottom: 40.0),
      width: 400.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 330.0,
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.person_outline),
                labelText: oldDisplayName.isEmpty ? 'Display name' : oldDisplayName,
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {
                  displayName = value;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Display name cannot be empty.';
                }

                return null;
              },
            ),
          ),

          if (displayName.length > 0 && displayName != oldDisplayName)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () {
                  updateDisplayName();
                },
                icon: Icon(Icons.save, color: Colors.green,),
              ),
            ),
        ],
      ),
    );
  }

  void updateDisplayName() async {
    if (userAuth == null) {
      checkAuthStatus();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // NOTE: Name unicity ?
      final userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = displayName;

      await userAuth.updateProfile(userUpdateInfo);

      await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .update(
          data: {
            'name': displayName,
            'nameLowerCase': displayName.toLowerCase(),
          }
        );

      setState(() {
        isLoading = false;
        oldDisplayName = displayName;
        displayName = '';
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Your display name has been successfully updated.'),
        )
      );

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while updating your display name. Please try again or contact us.'),
        )
      );
    }
  }
}
