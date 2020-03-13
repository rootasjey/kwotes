import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/components/web/settings_card.dart';
import 'package:memorare/components/web/settings_color_card.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isLoading          = false;
  bool isCompleted        = false;
  bool isLoadingImageURL  = false;

  FirebaseUser userAuth;

  String avatarUrl      = '';
  String displayName    = '';
  String email          = '';
  String imageUrl       = '';
  String oldDisplayName = '';
  String selectedLang   = 'English';

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

          FadeInY(
            beginY: 50.0,
            child: headerTitle(),
          ),

          FadeInY(
            delay: 1.0,
            beginY: 50.0,
            child: headerSubtitle(),
          ),

          FadeInY(
            delay: 1.5,
            beginY: 50.0,
            child: avatar(),
          ),

          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child: inputDisplayName(),
          ),

          FadeInY(
            delay: 2.5,
            beginY: 50.0,
            child: langSelect(),
          ),

          accountActions(),

          NavBackFooter(),
        ],
      ),
    );
  }

  Widget accountActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: SizedBox(
        width: 800.0,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            FadeInX(
              delay: 3.0,
              beginX: 50.0,
              child: SettingsCard(
                icon: Icon(Icons.email, size: 40.0,),
                name: 'Update email',
                onTap: () {
                  FluroRouter.router.navigateTo(context, EditEmailRoute);
                },
              ),
            ),

            FadeInX(
              delay: 3.5,
              beginX: 50.0,
              child: SettingsCard(
                icon: Icon(Icons.lock, size: 40.0,),
                name: 'Update password',
                onTap: () {
                  FluroRouter.router.navigateTo(context, EditPasswordRoute);
                },
              ),
            ),

            FadeInX(
              delay: 4.0,
              beginX: 50.0,
              child: SettingsColorCard(
                backgroundColor: Color(0xFFF85C50),
                color: Colors.white,
                icon: Icon(Icons.delete, size: 40.0, color: Colors.white,),
                name: 'Delete account',
                onTap: () {
                  FluroRouter.router.navigateTo(context, DeleteAccountRoute);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget avatar() {
    if (isLoadingImageURL) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: SizedBox(
          width: 200.0,
          height: 200.0,
          child: Column(
            children: <Widget>[
              CircularProgressIndicator(),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Updating profile image...',
                ),
              ),
            ],
          ),
        ),
      );
    }

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
          image: networkImage ?? assetImage,
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
                    content: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Opacity(
                                opacity: .6,
                                child: SizedBox(
                                  width: 300.0,
                                  child: Text(
                                    'You can provide a new URL for your image here',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                )
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 50.0),
                              child: SizedBox(
                                width: 300.0,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.image),
                                    labelText: 'Image URL',
                                  ),
                                  onChanged: (value) {
                                    imageUrl = value;
                                  },
                                ),
                              ),
                            ),

                            RaisedButton(
                              color: Color(0xFF58595B),
                              onPressed: () {
                                updateImageUrl();
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: SizedBox(
                                width: 400.0,
                                height: 400.0,
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: networkImage ?? assetImage,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close),
                          ),
                        ),
                      ],
                    )
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget headerSubtitle() {
    return Padding(
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
    );
  }

  Widget headerTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        'Account Settings',
        style: TextStyle(
          fontSize: 30.0,
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

  Widget langSelect() {
    return DropdownButton<String>(
      elevation: 3,
      value: selectedLang,
      onChanged: (String newValue) {
        setState(() {
          selectedLang = newValue;
        });

        updateLang();
      },
      items: ['English', 'Français']
        .map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value,)
          );
        })
        .toList(),
    );
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

    fetchLang();
  }

  void fetchLang() async {
    await Language.fetch(userAuth);

    setState(() {
      selectedLang = Language.frontend(Language.current);
    });
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

  void updateImageUrl() async {
    if (userAuth == null) {
      checkAuthStatus();
      return;
    }

    setState(() {
      isLoadingImageURL = true;
    });

    try {
      final userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.photoUrl = imageUrl;
      await userAuth.updateProfile(userUpdateInfo);

      setState(() {
        isLoadingImageURL = false;
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Your image has been successfully updated.'),
        )
      );

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingImageURL = false;
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while updating your image URL. Please try again or contact us.'),
        )
      );
    }
  }

  void updateLang() async {
    if (userAuth == null) {
      checkAuthStatus();
      return;
    }

    final lang = Language.backend(selectedLang);

    try {
      await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .update(
          data: {
            'lang': lang,
          }
        );

      Language.current = lang;

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Your language has been successfully updated.'
          ),
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
          content: Text('Error while updating your language. Please try again or contact us.'),
        )
      );
    }
  }
}
